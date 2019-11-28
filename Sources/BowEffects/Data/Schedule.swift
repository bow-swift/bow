import Foundation
import Bow

public enum Unit: Error {
    case unit
}

public class Schedule<R, A, State, B> {
    let initial: EnvIO<R, Never, State>
    let extract: (A, State) -> B
    let update: (A, State) -> EnvIO<R, Unit, State>
    
    init(initial: EnvIO<R, Never, State>,
         extract: @escaping (A, State) -> B,
         update: @escaping (A, State) -> EnvIO<R, Unit, State>) {
        self.initial = initial
        self.extract = extract
        self.update = update
    }
    
    public func and<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), (B, C)> {
        Schedule<R, A, (State, State2), (B, C)>(
            initial: EnvIO<R, Never, (State, State2)>.parZip(self.initial, that.initial)^,
            extract: { a, s in (self.extract(a, s.0), that.extract(a, s.1)) },
            update: { a, s in EnvIO<R, Unit, (State, State2)>.parZip(self.update(a, s.0), that.update(a, s.1))^ }
        )
    }
    
    public func split<State2, C, D>(_ that: Schedule<R, C, State2, D>) -> Schedule<R, (A, C), (State, State2), (B, D)> {
        Schedule<R, (A, C), (State, State2), (B, D)>(
            initial: self.initial.zip(that.initial),
            extract: { a, s in (self.extract(a.0, s.0), that.extract(a.1, s.1)) },
            update: { a, s in EnvIO<R, Unit, (State, State2)>.parZip(self.update(a.0, s.0), that.update(a.1, s.1))^ }
        )
    }
    
    public func choose<State2, C, D>(_ that: Schedule<R, C, State2, D>) -> Schedule<R, Either<A, C>, (State, State2), Either<B, D>> {
        Schedule<R, Either<A, C>, (State, State2), Either<B, D>>(
            initial: self.initial.zip(that.initial),
            extract: { a, s in
                a.fold({ aa in .left(self.extract(aa, s.0)) },
                       { c in .right(that.extract(c, s.1)) })
            },
            update: { a, s in
                a.fold({ aa in self.update(aa, s.0).map { x in (x, s.1) }^ },
                       { c in that.update(c, s.1).map { x in (s.0, x) }^ })
            }
        )
    }
    
    public func choose<State2, C>(_ that: Schedule<R, C, State2, B>) -> Schedule<R, Either<A, C>, (State, State2), B> {
        self.choose(that).map { b in b.fold(id, id) }
    }
    
    public func zip<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), (B, C)> {
        self.and(that)
    }
    
    public func zipRight<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), C> {
        self.and(that).map { x in x.1 }
    }
    
    public func zipLeft<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), B> {
        self.and(that).map { x in x.0 }
    }
    
    public func pipe<State2, C>(_ that: Schedule<R, B, State2, C>) -> Schedule<R, A, (State, State2), C> {
        Schedule<R, A, (State, State2), C>(
            initial: self.initial.zip(that.initial),
            extract: { a, s in that.extract(self.extract(a, s.0), s.1) },
            update: { a, s in
                let s1 = EnvIO<R, Unit, State>.var()
                let s2 = EnvIO<R, Unit, State2>.var()
                
                return binding(
                    s1 <- self.update(a, s.0),
                    s2 <- that.update(self.extract(a, s.0), s.1),
                    yield: (s1.get, s2.get))^
            }
        )
    }
    
    public func reversePipe<State2, C>(_ that: Schedule<R, C, State2, A>) -> Schedule<R, C, (State2, State), B> {
        that.pipe(self)
    }
    
    public func or<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), (B, C)> {
        Schedule<R, A, (State, State2), (B, C)>(
            initial: self.initial.zip(that.initial),
            extract: { a, s in (self.extract(a, s.0), that.extract(a, s.1)) },
            update: { a, s in
                EnvIO.race(self.update(a, s.0),
                           that.update(a, s.1)).map { either in
                    either.fold(
                        { s0 in (s0, s.1) },
                        { s1 in (s.0, s1)})
                }^
            })
    }
    
    public func addDelay(_ f: @escaping (B) -> DispatchTimeInterval) -> Schedule<R, A, State, B> {
        addDelayM { b in EnvIO<R, Never, DispatchTimeInterval>.pure(f(b))^ }
    }
    
    public func addDelayM(_ f: @escaping (B) -> EnvIO<R, Never, DispatchTimeInterval>) -> Schedule<R, A, State, B> {
        addDelayM { b in f(b).map { x in x.toDouble() ?? 0 }^ }
    }
    
    public func addDelay(_ f: @escaping (B) -> TimeInterval) -> Schedule<R, A, State, B> {
        addDelayM { b in EnvIO<R, Never, TimeInterval>.pure(f(b))^ }
    }
    
    public func addDelayM(_ f: @escaping (B) -> EnvIO<R, Never, TimeInterval>) -> Schedule<R, A, State, B> {
        updated { upd in
            { a, s in
                let delay = EnvIO<R, Unit, TimeInterval>.var()
                let s1 = EnvIO<R, Unit, State>.var()
                return binding(
                    delay <- f(self.extract(a, s)).unitError(),
                    s1 <- upd(a, s),
                    |<-EnvIO.sleep(delay.get),
                    yield: s1.get)^
            }
        }
    }
    
    public func andThen<State2>(_ that: Schedule<R, A, State2, B>) -> Schedule<R, A, Either<State, State2>, B> {
        andThenEither(that).map { x in x.fold(id, id) }
    }
    
    public func andThenEither<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, Either<State, State2>, Either<B, C>> {
        Schedule<R, A, Either<State, State2>, Either<B, C>>(
            initial: self.initial.map(Either.left)^,
            extract: { a, s in
                s.fold({ s1 in .left(self.extract(a, s1)) },
                       { s2 in .right(that.extract(a, s2)) })
            },
            update: { a, s in
                s.fold({ s1 in
                    self.update(a, s1).map(Either.left)
                        .handleErrorWith { _ in
                            that.initial.unitError().flatMap { x in that.update(a, x) }.map(Either.right)^
                        }^
                },
                       { s2 in that.update(a, s2).map(Either.right)^ })
            })
    }
    
    public func `as`<C>(_ c: C) -> Schedule<R, A, State, C> {
        map { _ in c }
    }
    
    public func both<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), (B, C)> {
        self.and(that)
    }
    
    public func bothWith<State2, C, D>(_ that: Schedule<R, A, State2, C>, _ f: @escaping (B, C) -> D) -> Schedule<R, A, (State, State2), D> {
        self.and(that).map(f)
    }
    
    public func check(_ test: @escaping (A, B) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, B> {
        updated { upd in
            { a, s in
                test(a, self.extract(a, s)).unitError().flatMap { flag in
                    flag ?
                        upd(a, s) :
                        EnvIO.raiseError(.unit)
                }^
            }
        }
    }
    
    public func collectAll() -> Schedule<R, A, (State, [B]), [B]> {
        fold([]) { xs, x in [x] + xs }.map { x in Array(x.reversed()) }
    }
    
    public func compose<State2, C>(_ that: Schedule<R, C, State2, A>) -> Schedule<R, C, (State2, State), B> {
        self.reversePipe(that)
    }
    
    public func contramap<AA>(_ f: @escaping (AA) -> A) -> Schedule<R, AA, State, B> {
        Schedule<R, AA, State, B>(
            initial: self.initial,
            extract: { a, s in self.extract(f(a), s) },
            update: { a, s in self.update(f(a), s) })
    }
    
    public func dimap<AA, C>(_ f: @escaping (AA) -> A, _ g: @escaping (B) -> C) -> Schedule<R, AA, State, C> {
        contramap(f).map(g)
    }
    
    public func either<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), (B, C)> {
        self.or(that)
    }
    
    public func eitherWith<State2, C, D>(_ that: Schedule<R, A, State2, C>, _ f: @escaping (B, C) -> D) -> Schedule<R, A, (State, State2), D> {
        self.or(that).map(f)
    }
    
    func first<C>() -> Schedule<R, (A, C), (State, Unit), (B, C)> {
        self.split(Schedule<R, C, Unit, C>.identity())
    }
    
    public func fold<Z>(_ z: Z, _ f: @escaping (Z, B) -> Z) -> Schedule<R, A, (State, Z), Z> {
        Schedule<R, A, (State, Z), Z>(
            initial: self.initial.map { x in (x, z) }^,
            extract: { a, s in f(s.1, self.extract(a, s.0)) },
            update: { a, s in
                self.update(a, s.0).map { s1 in (s1, f(s.1, self.extract(a, s.0))) }^
            })
    }
    
    public func forever() -> Schedule<R, A, State, B> {
        Schedule(
            initial: self.initial,
            extract: self.extract,
            update: { a, s in self.update(a, s).handleErrorWith { _ in
                self.initial.unitError().flatMap { x in self.update(a, x) }
            }^ })
    }
    
    public func initialized(_ f: @escaping (EnvIO<R, Never, State>) -> EnvIO<R, Never, State>) -> Schedule<R, A, State, B> {
        Schedule(
            initial: f(self.initial),
            extract: self.extract,
            update: self.update)
    }
    
    func left<C>() -> Schedule<R, Either<A, C>, (State, Unit), Either<B, C>> {
        self.choose(Schedule<R, C, Unit, C>.identity())
    }
    
    public func map<C>(_ f: @escaping (B) -> C) -> Schedule<R, A, State, C> {
        Schedule<R, A, State, C>(
            initial: self.initial,
            extract: { a, s in f(self.extract(a, s)) },
            update: self.update)
    }
    
    public func repetitions() -> Schedule<R, A, (State, Int), Int> {
        fold(0) { n, _ in n + 1 }
    }
    
    public func tapInput(_ f: @escaping (A) -> EnvIO<R, Never, Void>) -> Schedule<R, A, State, B> {
        updated { upd in
            { a, s in
                f(a).unitError().flatMap { _ in upd(a, s) }^
            }
        }
    }
    
    public func tapOutput(_ f: @escaping (B) -> EnvIO<R, Never, Void>) -> Schedule<R, A, State, B> {
        updated { upd in
            { a, s in
                upd(a, s).flatMap { ss in f(self.extract(a, ss)).unitError().as(ss) }^
            }
        }
    }
    
    func updated(_ f: @escaping (@escaping (A, State) -> EnvIO<R, Unit, State>) -> (A, State) -> EnvIO<R, Unit, State>) -> Schedule<R, A, State, B> {
        Schedule(
            initial: self.initial,
            extract: self.extract,
            update: f(self.update)
        )
    }
    
    public func void() -> Schedule<R, A, State, Void> {
        `as`(())
    }
    
    public func untilInput(_ f: @escaping (A) -> Bool) -> Schedule<R, A, State, B> {
        untilInputM { a in EnvIO.pure(f(a))^ }
    }
    
    public func untilInputM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, B> {
        updated { upd in
            { a, s in
                f(a).unitError().flatMap { flag in
                    flag ?
                        EnvIO.raiseError(.unit)^ :
                        upd(a, s)
                }^
            }
        }
    }
    
    public func untilOutput(_ f: @escaping (B) -> Bool) -> Schedule<R, A, State, B> {
        untilOutputM { b in EnvIO.pure(f(b))^ }
    }
    
    public func untilOutputM(_ f: @escaping (B) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, B> {
        updated { upd in
            { a, s in
                f(self.extract(a, s)).unitError().flatMap { flag in
                    flag ?
                        EnvIO.raiseError(.unit)^ :
                        upd(a, s)
                }^
            }
        }
    }
    
    public func whileInput(_ f: @escaping (A) -> Bool) -> Schedule<R, A, State, B> {
        whileInputM { a in EnvIO.pure(f(a))^ }
    }
    
    public func whileInputM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, B> {
        check { a, _ in f(a) }
    }
    
    public func whileOutput(_ f: @escaping (B) -> Bool) -> Schedule<R, A, State, B> {
        whileOutputM { b in EnvIO.pure(f(b))^ }
    }
    
    public func whileOutputM(_ f: @escaping (B) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, B> {
        check { _, b in f(b) }
    }
    
    public static func unfold(_ a: B, _ f: @escaping (B) -> B) -> Schedule<R, A, B, B> {
        unfoldM(EnvIO.pure(a)^, { a in EnvIO.pure(f(a))^ })
    }
    
    public static func unfoldM(_ a: EnvIO<R, Never, B>, _ f: @escaping (B) -> EnvIO<R, Never, B>) -> Schedule<R, A, B, B> {
        Schedule<R, A, B, B>(
            initial: a,
            extract: { _, a in a },
            update: { _, a in f(a).unitError() }
        )
    }
}

extension Schedule where B == DispatchTimeInterval {
    public static func delayed(_ s: Schedule<R, A, State, DispatchTimeInterval>) -> Schedule<R, A, State, DispatchTimeInterval> {
        s.addDelay(id)
    }
}

extension Schedule where B == TimeInterval {
    public static func delayed(_ s: Schedule<R, A, State, TimeInterval>) -> Schedule<R, A, State, TimeInterval> {
        s.addDelay(id)
    }
}

extension Schedule where State == (DispatchTime, DispatchTimeInterval), B == DispatchTimeInterval {
    private static func now() -> EnvIO<R, Never, DispatchTime> {
        EnvIO.pure(DispatchTime.now())^
    }
    
    public static func elapsed() -> Schedule<R, A, (DispatchTime, DispatchTimeInterval), DispatchTimeInterval> {
        Schedule<R, A, (DispatchTime, DispatchTimeInterval), DispatchTimeInterval>(
            initial: now().map { s in (s, DispatchTimeInterval.seconds(0)) }^,
            extract: { _, s in s.1 },
            update: { _, s in now().unitError().map { currentTime in (s.0, currentTime - s.0) }^ }
        )
    }
    
    public static func duration(_ interval: DispatchTimeInterval) -> Schedule<R, A, (DispatchTime, DispatchTimeInterval), DispatchTimeInterval> {
        elapsed().untilOutput { x in x >= interval }
    }
}

extension Schedule where State == Int, B == Int {
    public static func spaced(_ interval: DispatchTimeInterval) -> Schedule<R, A, State, Int> {
        forever().addDelay { _ in interval }
    }
    
    public static func spaced(_ interval: TimeInterval) -> Schedule<R, A, State, Int> {
        forever().addDelay { _ in interval }
    }
}

extension Schedule where State == Int, B == TimeInterval {
    public static func exponential(_ base: DispatchTimeInterval, factor: Double = 2.0) -> Schedule<R, A, Int, TimeInterval> {
        exponential(base.toDouble() ?? 1, factor: factor)
    }
    
    public static func exponential(_ base: TimeInterval, factor: Double = 2.0) -> Schedule<R, A, Int, TimeInterval> {
        delayed(Schedule<R, A, Int, Int>.forever().map { i in
            base * pow(factor, Double(i + 1))
        })
    }
    
    public static func linear(_ base: DispatchTimeInterval) -> Schedule<R, A, Int, TimeInterval> {
        linear(base.toDouble() ?? 1)
    }
    
    public static func linear(_ base: TimeInterval) -> Schedule<R, A, Int, TimeInterval> {
        delayed(Schedule<R, A, Int, Int>.forever().map { i in
            base * Double(i + 1)
        })
    }
}

extension Schedule where State == (TimeInterval, TimeInterval), B == TimeInterval {
    public static func fibonacci(_ one: DispatchTimeInterval) -> Schedule<R, A, (TimeInterval, TimeInterval), TimeInterval> {
        delayed(
            Schedule<R, A, (TimeInterval, TimeInterval), (TimeInterval, TimeInterval)>.unfold((one.toDouble() ?? 1, one.toDouble() ?? 1)) { x in (x.1, x.0 + x.1) }.map { x in x.0 })
    }
}

extension Schedule where B == Void, State == Unit {
    public static func void() -> Schedule<R, A, Unit, Void> {
        Schedule<R, A, Unit, A>.identity().void()
    }
}

extension Schedule where A == B, State == Unit {
    public static func identity() -> Schedule<R, A, Unit, A> {
        Schedule<R, A, Unit, A>(
            initial: EnvIO.pure(.unit)^,
            extract: { a, _ in a },
            update: { _, _ in EnvIO.pure(.unit)^ })
    }
    
    public static func doWhile(_ f: @escaping (A) -> Bool) -> Schedule<R, A, Unit, A> {
        doWhileM { a in EnvIO.pure(f(a))^ }
    }
    
    public static func doWhileM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, Unit, A> {
        identity().whileInputM(f)
    }
    
    public static func doUntil(_ f: @escaping (A) -> Bool) -> Schedule<R, A, Unit, A> {
        doUntilM { a in EnvIO.pure(f(a))^ }
    }
    
    public static func doUntilM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, Unit, A> {
        identity().untilInputM(f)
    }
    
    public static func tapInput(_ f: @escaping (A) -> EnvIO<R, Never, Void>) -> Schedule<R, A, Unit, A> {
        identity().tapInput(f)
    }
    
    public static func tapOutput(_ f: @escaping (A) -> EnvIO<R, Never, Void>) -> Schedule<R, A, Unit, A> {
        identity().tapOutput(f)
    }
}

extension Schedule where State == Unit {
    public static func from(function: @escaping (A) -> B) -> Schedule<R, A, State, B> {
        Schedule<R, A, Unit, A>.identity().map(function)
    }
}

extension Schedule where A == B, State == Unit, A: Equatable {
    public static func doWhileEquals(_ a: A) -> Schedule<R, A, Unit, A> {
        identity().whileInput { x in x == a }
    }
    
    public static func doUntilEquals(_ a: A) -> Schedule<R, A, Unit, A> {
        identity().untilInput { x in x == a }
    }
}

extension Schedule where B == Int, State == Int {
    public static func forever() -> Schedule<R, A, Int, Int> {
        Schedule<R, A, Int, Int>.unfold(0) { $0 + 1 }
    }
    
    public static func recurs(_ n: Int) -> Schedule<R, A, Int, Int> {
        forever().whileOutput { $0 < n }
    }
    
    public static func once() -> Schedule<R, A, Int, Void> {
        recurs(1).void()
    }
    
    public static func stop() -> Schedule<R, A, Int, Void> {
        recurs(0).void()
    }
}

extension Schedule where B == Never, A == Any, State == Never {
    public static func never() -> Schedule<R, Any, Never, Never> {
        Schedule(
            initial: EnvIO { _ in IO.never() },
            extract: { _, never in never },
            update: { _, _ in EnvIO { _ in IO.never() }})
    }
}

extension Schedule where B == [A], State == (Unit, [A]) {
    public static func collectAll() -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.identity().collectAll()
    }
    
    public static func collectWhile(_ f: @escaping (A) -> Bool) -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.doWhile(f).collectAll()
    }
    
    public static func collectWhileM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.doWhileM(f).collectAll()
    }
    
    public static func collectUntil(_ f: @escaping (A) -> Bool) -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.doUntil(f).collectAll()
    }
    
    public static func collectUntilM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.doUntilM(f).collectAll()
    }
}

extension Kleisli {
    func unitError<E: Error>() -> EnvIO<D, Unit, A> where F == IOPartial<E> {
        self.mapError { _ in .unit }
    }
}
