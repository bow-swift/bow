import Foundation
import Bow

/// A single error. This is a workaround over not being able to make `Void` conform to `Error`.
public enum Unit: Error {
    case unit
}

/// A stateful, effectful and recurring schedule of actions.
///
/// A schedule consumes values of type `A` and based on its internal state of type `State`, decides to continue or stop. Every decision has a delay and an output of type `B`.
public class Schedule<R, A, State, B> {
    /// Initial state for this schedule.
    let initial: EnvIO<R, Never, State>
    
    /// Extract the output if this schedule based on an input and its internal state.
    let extract: (A, State) -> B
    
    /// Update the state of this schedule based on an input and its internal state.
    let update: (A, State) -> EnvIO<R, Unit, State>
    
    init(initial: EnvIO<R, Never, State>,
         extract: @escaping (A, State) -> B,
         update: @escaping (A, State) -> EnvIO<R, Unit, State>) {
        self.initial = initial
        self.extract = extract
        self.update = update
    }
    
    /// Composes this schedule with another one, providing a new schedule that continues as long as both continue, using the maximum delay of the two schedules.
    ///
    /// - Parameter that: Schedule to be composed with this one.
    public func and<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), (B, C)> {
        Schedule<R, A, (State, State2), (B, C)>(
            initial: EnvIO<R, Never, (State, State2)>.parZip(self.initial, that.initial)^,
            extract: { a, s in (self.extract(a, s.0), that.extract(a, s.1)) },
            update: { a, s in EnvIO<R, Unit, (State, State2)>.parZip(self.update(a, s.0), that.update(a, s.1))^ }
        )
    }
    
    /// Composes this schedule with another one, providing a new schedule that needs the input of both schedules and provides the output of both. It continues as long as both continue, using the maximum delay of the two schedules.
    ///
    /// - Parameter that: Schedule to be composed with this one.
    public func split<State2, C, D>(_ that: Schedule<R, C, State2, D>) -> Schedule<R, (A, C), (State, State2), (B, D)> {
        Schedule<R, (A, C), (State, State2), (B, D)>(
            initial: self.initial.zip(that.initial),
            extract: { a, s in (self.extract(a.0, s.0), that.extract(a.1, s.1)) },
            update: { a, s in EnvIO<R, Unit, (State, State2)>.parZip(self.update(a.0, s.0), that.update(a.1, s.1))^ }
        )
    }
    
    /// Chooses between two schedules with different inputs and outputs.
    ///
    /// - Parameter that: Schedule to be composed with this one.
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
    
    /// Chooses between two schedules with different inputs and the same output.
    ///
    /// - Parameter that: Schedule to be composed with this one.
    public func choose<State2, C>(_ that: Schedule<R, C, State2, B>) -> Schedule<R, Either<A, C>, (State, State2), B> {
        self.choose(that).map { b in b.merge() }
    }
    
    /// Composes this schedule with another one, providing a new schedule that continues as long as both continue, using the maximum delay of the two schedules.
    ///
    /// - Parameter that: Schedule to be composed with this one.
    public func zip<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), (B, C)> {
        self.and(that)
    }
    
    /// Composes this schedule with another one, providing a new schedule that continues as long as both continue, using the maximum delay of the two schedules, and ignoring the output of this schedule.
    ///
    /// - Parameter that: Schedule to be composed with this one.
    public func zipRight<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), C> {
        self.and(that).map { x in x.1 }
    }
    
    /// Composes this schedule with another one, providing a new schedule that continues as long as both continue, using the maximum delay of the two schedules, and ignoring the output of the provided schedule.
    ///
    /// - Parameter that: Schedule to be composed with this one.
    public func zipLeft<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), B> {
        self.and(that).map { x in x.0 }
    }
    
    /// Pipes the output of this schedule as the input of the provided one. Effects described by this schedule will always be performed before the effects described by the second schedule.
    ///
    /// - Parameter that: Schedule to be piped after this one.
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
    
    /// Pipes the output of the provided schedule as the input of this schedule. Effects described by the provided schedule will always be performed before the effects described by this schedule.
    ///
    /// - Parameter that: Schedule to be piped before this one.
    public func reversePipe<State2, C>(_ that: Schedule<R, C, State2, A>) -> Schedule<R, C, (State2, State), B> {
        that.pipe(self)
    }
    
    /// Composes with a schedule resulting in another one that continues as long as either schedule continues, using the minimum of the delays of the two schedules.
    ///
    /// - Parameter that: Schedule to be composed with this one.
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
    
    /// Adds a delay of the specified duration based on the output of this schedule.
    ///
    /// - Parameter f: Function computing the delay time based on the output of the schedule.
    public func addDelay(_ f: @escaping (B) -> DispatchTimeInterval) -> Schedule<R, A, State, B> {
        addDelayM { b in EnvIO<R, Never, DispatchTimeInterval>.pure(f(b))^ }
    }
    
    /// Adds a delay of the specified duration based on the output of this schedule.
    ///
    /// - Parameter f: An effectful function that provides the delay time based on the output of the schedule.
    public func addDelayM(_ f: @escaping (B) -> EnvIO<R, Never, DispatchTimeInterval>) -> Schedule<R, A, State, B> {
        addDelayM { b in f(b).map { x in x.toDouble() ?? 0 }^ }
    }
    
    /// Adds a delay of the specified duration based on the output of this schedule.
    ///
    /// - Parameter f: Function computing the delay time based on the output of the schedule.
    public func addDelay(_ f: @escaping (B) -> TimeInterval) -> Schedule<R, A, State, B> {
        addDelayM { b in EnvIO<R, Never, TimeInterval>.pure(f(b))^ }
    }
    
    /// Adds a delay of the specified duration based on the output of this schedule.
    ///
    /// - Parameter f: An effectful function that provides the delay time based on the output of the schedule.
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
    
    /// Composes two schedules with the same input and output by applying them sequentially. It executes the first to completion, and then executes the second.
    ///
    /// - Parameter that: Schedule to be composed with this one.
    public func andThen<State2>(_ that: Schedule<R, A, State2, B>) -> Schedule<R, A, Either<State, State2>, B> {
        andThenEither(that).map { x in x.merge() }
    }
    
    /// Composes two schedules with the same input but different outputs by applying them sequentially. It executes the first to completion, and then executes the second.
    ///
    /// - Parameter that: Schedule to be composed with this one.
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
    
    /// Transforms the output of this schedule to a fixed value.
    ///
    /// - Parameter c: Fixed value to return as output of this schedule.
    public func `as`<C>(_ c: C) -> Schedule<R, A, State, C> {
        map { _ in c }
    }
    
    /// Composes this schedule with another one, providing a new schedule that continues as long as both continue, using the maximum delay of the two schedules.
    ///
    /// - Parameter that: Schedule to be composed with this one.
    public func both<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), (B, C)> {
        self.and(that)
    }
    
    /// Composes this schedule with another one, providing a new schedule that continues as long as both continue, using the maximum delay of the two schedules, and combining the outputs of both using the provided function.
    ///
    /// - Parameters:
    ///     - that: Schedule to be composed with this one.
    ///     - f: Transforming function.
    public func bothWith<State2, C, D>(_ that: Schedule<R, A, State2, C>, _ f: @escaping (B, C) -> D) -> Schedule<R, A, (State, State2), D> {
        self.and(that).map(f)
    }
    
    /// Peeks at the output produced by this schedule and executes a test to determine if the schedule should continue or not.
    ///
    /// - Parameter test: Effectful predicate to determine if the schedule should continue or not based on the current input and output.
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
    
    /// Collects all the output of this schedule in an array.
    public func collectAll() -> Schedule<R, A, (State, [B]), [B]> {
        fold([]) { xs, x in xs + [x] }
    }
    
    /// Pipes the output of the provided schedule as the input of this schedule. Effects described by the provided schedule will always be performed before the effects described by this schedule.
    ///
    /// - Parameter that: Schedule to be piped before this one.
    public func compose<State2, C>(_ that: Schedule<R, C, State2, A>) -> Schedule<R, C, (State2, State), B> {
        self.reversePipe(that)
    }
    
    /// Provides an schedule that deals with a narrower class of inputs than this schedule.
    ///
    /// - Parameter f: Function transforming the input of this schedule.
    public func contramap<AA>(_ f: @escaping (AA) -> A) -> Schedule<R, AA, State, B> {
        Schedule<R, AA, State, B>(
            initial: self.initial,
            extract: { a, s in self.extract(f(a), s) },
            update: { a, s in self.update(f(a), s) })
    }
    
    /// Provides an schedule that contramaps the input and maps the output with the provided functions.
    ///
    /// - Parameters:
    ///   - f: Function to contramap.
    ///   - g: Function to map.
    public func dimap<AA, C>(_ f: @escaping (AA) -> A, _ g: @escaping (B) -> C) -> Schedule<R, AA, State, C> {
        contramap(f).map(g)
    }
    
    /// Composes with a schedule resulting in another one that continues as long as either schedule continues, using the minimum of the delays of the two schedules.
    ///
    /// - Parameter that: Schedule to be composed with this one.
    public func either<State2, C>(_ that: Schedule<R, A, State2, C>) -> Schedule<R, A, (State, State2), (B, C)> {
        self.or(that)
    }
    
    /// Composes with a schedule resulting in another one that continues as long as either schedule continues, using the minimum of the delays of the two schedules, and transforming the outputs with the provided function.
    ///
    /// - Parameters:
    ///     - that: Schedule to be composed with this one.
    ///     - f: Transforming function.
    public func eitherWith<State2, C, D>(_ that: Schedule<R, A, State2, C>, _ f: @escaping (B, C) -> D) -> Schedule<R, A, (State, State2), D> {
        self.or(that).map(f)
    }
    
    /// Puts this schedule into the first element of a tuple and passes an unmodified element as the second element of the tuple.
    public func first<C>() -> Schedule<R, (A, C), (State, Unit), (B, C)> {
        self.split(Schedule<R, C, Unit, C>.identity())
    }
    
    /// Provides a schedule that folds the outputs of this one.
    ///
    /// - Parameters:
    ///   - z: Initial value for the folding process.
    ///   - f: Folding function.
    public func fold<Z>(_ z: Z, _ f: @escaping (Z, B) -> Z) -> Schedule<R, A, (State, Z), Z> {
        Schedule<R, A, (State, Z), Z>(
            initial: self.initial.map { x in (x, z) }^,
            extract: { a, s in f(s.1, self.extract(a, s.0)) },
            update: { a, s in
                self.update(a, s.0).map { s1 in (s1, f(s.1, self.extract(a, s.0))) }^
            })
    }
    
    /// Returns a new schedule that loops this one forever, resetting the state when this schedule is completed.
    public func forever() -> Schedule<R, A, State, B> {
        Schedule(
            initial: self.initial,
            extract: self.extract,
            update: { a, s in self.update(a, s).handleErrorWith { _ in
                self.initial.unitError().flatMap { x in self.update(a, x) }
            }^ })
    }
    
    /// Returns a new schedule with the specified initial state transformed by a function.
    ///
    /// - Parameter f: Function transforming the initial state.
    public func initialized(_ f: @escaping (EnvIO<R, Never, State>) -> EnvIO<R, Never, State>) -> Schedule<R, A, State, B> {
        Schedule(
            initial: f(self.initial),
            extract: self.extract,
            update: self.update)
    }
    
    /// Puts the schedule into the left side of an `Either` and passes an unmodified value as the right side of the `Either`.
    public func left<C>() -> Schedule<R, Either<A, C>, (State, Unit), Either<B, C>> {
        self.choose(Schedule<R, C, Unit, C>.identity())
    }
    
    /// Transforms the output of this schedule with the provided function.
    ///
    /// - Parameter f: Transforming function.
    public func map<C>(_ f: @escaping (B) -> C) -> Schedule<R, A, State, C> {
        Schedule<R, A, State, C>(
            initial: self.initial,
            extract: { a, s in f(self.extract(a, s)) },
            update: self.update)
    }
    
    /// Provides a new schedule that emits the number of repetitions of this schedule.
    public func repetitions() -> Schedule<R, A, (State, Int), Int> {
        fold(0) { n, _ in n + 1 }
    }
    
    /// Puts the schedule into the right side of an `Either` and passes an unmodified value as the left side of the `Either`.
    public func right<C>() -> Schedule<R, Either<C, A>, (Unit, State), Either<C, B>> {
        Schedule<R, C, Unit, C>.identity().choose(self)
    }
    
    /// Puts this schedule into the second element of a tuple and passes an unmodified element as the first element of the tuple.
    public func second<C>() -> Schedule<R, (C, A), (Unit, State), (C, B)> {
        Schedule<R, C, Unit, C>.identity().split(self)
    }
    
    /// Performs an additional effect for every input.
    ///
    /// - Parameter f: Effectful function to run after every input.
    public func tapInput(_ f: @escaping (A) -> EnvIO<R, Never, Void>) -> Schedule<R, A, State, B> {
        updated { upd in
            { a, s in
                f(a).unitError().flatMap { _ in upd(a, s) }^
            }
        }
    }
    
    /// Performs an additional effect for every output.
    ///
    /// - Parameter f: Effectful function to run after every output.
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
    
    /// Wipes out the output produced by this schedule.
    public func void() -> Schedule<R, A, State, Void> {
        `as`(())
    }
    
    /// Provides a schedule that iterates this schedule until the input matches a given predicate.
    ///
    /// - Parameter f: Predicate to test the input of this schedule.
    public func untilInput(_ f: @escaping (A) -> Bool) -> Schedule<R, A, State, B> {
        untilInputM { a in EnvIO.pure(f(a))^ }
    }
    
    /// Provides a schedule that iterates this schedule until the input matches a given effectful predicate.
    ///
    /// - Parameter f: Effectful predicate to test the input of this schedule.
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
    
    /// Provides a schedule that iterates this schedule until the output matches a given predicate.
    ///
    /// - Parameter f: Predicate to test the output of this schedule.
    public func untilOutput(_ f: @escaping (B) -> Bool) -> Schedule<R, A, State, B> {
        untilOutputM { b in EnvIO.pure(f(b))^ }
    }
    
    /// Provides a schedule that iterates this schedule until the output matches a given effectful predicate.
    ///
    /// - Parameter f: Effectful predicate to test the output of this schedule.
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
    
    /// Provides a schedule that iterates this schedule while the input matches a given predicate.
    ///
    /// - Parameter f: Predicate to test the input of this schedule.
    public func whileInput(_ f: @escaping (A) -> Bool) -> Schedule<R, A, State, B> {
        whileInputM { a in EnvIO.pure(f(a))^ }
    }
    
    /// Provides a schedule that iterates this schedule while the input matches a given effectful predicate.
    ///
    /// - Parameter f: Effectful predicate to test the input of this schedule.
    public func whileInputM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, B> {
        check { a, _ in f(a) }
    }
    
    /// Provides a schedule that iterates this schedule while the output matches a given predicate.
    ///
    /// - Parameter f: Predicate to test the output of this schedule.
    public func whileOutput(_ f: @escaping (B) -> Bool) -> Schedule<R, A, State, B> {
        whileOutputM { b in EnvIO.pure(f(b))^ }
    }
    
    /// Provides a schedule that iterates this schedule while the output matches a given effectful predicate.
    ///
    /// - Parameter f: Effectful predicate to test the output of this schedule.
    public func whileOutputM(_ f: @escaping (B) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, B> {
        check { _, b in f(b) }
    }
    
    /// Provides a schedule that always recurs without delay and computes the output through subsequent applications of a function to an initial value.
    ///
    /// - Parameters:
    ///   - a: Initial value.
    ///   - f: Unfolding function.
    public static func unfold(_ a: B, _ f: @escaping (B) -> B) -> Schedule<R, A, B, B> {
        unfoldM(EnvIO.pure(a)^, { a in EnvIO.pure(f(a))^ })
    }
    
    /// Provides a schedule that always recurs without delay and computes the output through subsequent applications of an effectful function to an initial value.
    ///
    /// - Parameters:
    ///   - a: Initial effect.
    ///   - f: Unfolding effectful function.
    public static func unfoldM(_ a: EnvIO<R, Never, B>, _ f: @escaping (B) -> EnvIO<R, Never, B>) -> Schedule<R, A, B, B> {
        Schedule<R, A, B, B>(
            initial: a,
            extract: { _, a in a },
            update: { _, a in f(a).unitError() }
        )
    }
}

extension Schedule where B == DispatchTimeInterval {
    /// Provides a schedule from the given schedule which transforms the delays into effectufl sleeps.
    ///
    /// - Parameter s: A schedule producing time intervals.
    public static func delayed(_ s: Schedule<R, A, State, DispatchTimeInterval>) -> Schedule<R, A, State, DispatchTimeInterval> {
        s.addDelay(id)
    }
}

extension Schedule where B == TimeInterval {
    /// Provides a schedule from the given schedule which transforms the delays into effectufl sleeps.
    ///
    /// - Parameter s: A schedule producing time intervals.
    public static func delayed(_ s: Schedule<R, A, State, TimeInterval>) -> Schedule<R, A, State, TimeInterval> {
        s.addDelay(id)
    }
}

extension Schedule where State == (DispatchTime, DispatchTimeInterval), B == DispatchTimeInterval {
    private static func now() -> EnvIO<R, Never, DispatchTime> {
        EnvIO.pure(DispatchTime.now())^
    }
    
    /// Provides a schedule that recurs forever without a delay, returning the elapsed time since it began.
    public static func elapsed() -> Schedule<R, A, (DispatchTime, DispatchTimeInterval), DispatchTimeInterval> {
        Schedule<R, A, (DispatchTime, DispatchTimeInterval), DispatchTimeInterval>(
            initial: now().map { s in (s, DispatchTimeInterval.seconds(0)) }^,
            extract: { _, s in s.1 },
            update: { _, s in now().unitError().map { currentTime in (s.0, currentTime - s.0) }^ }
        )
    }
    
    /// Provides a schedule that recurs until the specified duration elapsed, returning the total elapsed time.
    ///
    /// - Parameter interval: Time interval for this schedule to recur.
    public static func duration(_ interval: DispatchTimeInterval) -> Schedule<R, A, (DispatchTime, DispatchTimeInterval), DispatchTimeInterval> {
        elapsed().untilOutput { x in x >= interval }
    }
}

extension Schedule where State == Int, B == Int {
    /// Provides a schedule that waits for the specified amount of time between each input. Returns the number of received inputs.
    ///
    /// - Parameter interval: Time interval to wait between each action.
    public static func spaced(_ interval: DispatchTimeInterval) -> Schedule<R, A, State, Int> {
        forever().addDelay { _ in interval }
    }
    
    /// Provides a schedule that waits for the specified amount of time between each input. Returns the number of received inputs.
    ///
    /// - Parameter interval: Time interval to wait between each action.
    public static func spaced(_ interval: TimeInterval) -> Schedule<R, A, State, Int> {
        forever().addDelay { _ in interval }
    }
}

extension Schedule where State == Int, B == TimeInterval {
    /// Provides a schedule that always recurs, waiting an amount of time between repetitions, given by an exponential backoff algorithm, and returning the current duration between recurrences.
    ///
    /// The time to wait is given by the formula `base * pow(n + 1)`, where `n` is the number of repetitions so far.
    ///
    /// - Parameters:
    ///   - base: Base time interval to wait between repetitions.
    ///   - factor: Factor for the exponential backoff. Defaults to 2.0.
    public static func exponential(_ base: DispatchTimeInterval, factor: Double = 2.0) -> Schedule<R, A, Int, TimeInterval> {
        exponential(base.toDouble() ?? 1, factor: factor)
    }
    
    /// Provides a schedule that always recurs, waiting an amount of time between repetitions, given by an exponential backoff algorithm, and returning the current duration between recurrences.
    ///
    /// The time to wait is given by the formula `base * pow(n + 1)`, where `n` is the number of repetitions so far.
    ///
    /// - Parameters:
    ///   - base: Base time interval to wait between repetitions.
    ///   - factor: Factor for the exponential backoff. Defaults to 2.0.
    public static func exponential(_ base: TimeInterval, factor: Double = 2.0) -> Schedule<R, A, Int, TimeInterval> {
        delayed(Schedule<R, A, Int, Int>.forever().map { i in
            base * pow(factor, Double(i + 1))
        })
    }
    
    /// Provides a schedule that always recurs, waiting an amount of time between repetitions, given by a linear backoff algorithm, and returning the current duration between recurrences.
    ///
    /// The time to wait is given by the formula `base * (n + 1)`, where `n` is the number of repetitions so far.
    ///
    /// - Parameter base: Base time interval to wait between repetitions.
    public static func linear(_ base: DispatchTimeInterval) -> Schedule<R, A, Int, TimeInterval> {
        linear(base.toDouble() ?? 1)
    }
    
    /// Provides a schedule that always recurs, waiting an amount of time between repetitions, given by a linear backoff algorithm, and returning the current duration between recurrences.
    ///
    /// The time to wait is given by the formula `base * (n + 1)`, where `n` is the number of repetitions so far.
    ///
    /// - Parameter base: Base time interval to wait between repetitions.
    public static func linear(_ base: TimeInterval) -> Schedule<R, A, Int, TimeInterval> {
        delayed(Schedule<R, A, Int, Int>.forever().map { i in
            base * Double(i + 1)
        })
    }
}

extension Schedule where State == (TimeInterval, TimeInterval), B == TimeInterval {
    
    /// Provides a schedule that always recurs, increasing delays by summing the preceding two delays, as in the Fibonacci sequence. Returns the current duration between recurrences.
    ///
    /// - Parameter one: Time interval for the initial delay.
    public static func fibonacci(_ one: DispatchTimeInterval) -> Schedule<R, A, (TimeInterval, TimeInterval), TimeInterval> {
        fibonacci(one.toDouble() ?? 1)
    }
    
    /// Provides a schedule that always recurs, increasing delays by summing the preceding two delays, as in the Fibonacci sequence. Returns the current duration between recurrences.
    ///
    /// - Parameter one: Time interval for the initial delay.
    public static func fibonacci(_ one: TimeInterval) -> Schedule<R, A, (TimeInterval, TimeInterval), TimeInterval> {
        delayed(
            Schedule<R, A, (TimeInterval, TimeInterval), (TimeInterval, TimeInterval)>.unfold((one, one)) { x in
                (x.1, x.0 + x.1)
            }.map { x in x.0 })
    }
}

extension Schedule where B == Void, State == Unit {
    /// Provides a schedule that wipes out the output.
    public static func void() -> Schedule<R, A, Unit, Void> {
        Schedule<R, A, Unit, A>.identity().void()
    }
}

extension Schedule where A == B, State == Unit {
    /// Provides a schedule that returns the input, unmodified.
    public static func identity() -> Schedule<R, A, Unit, A> {
        Schedule<R, A, Unit, A>(
            initial: EnvIO.pure(.unit)^,
            extract: { a, _ in a },
            update: { _, _ in EnvIO.pure(.unit)^ })
    }
    
    /// Provides a schedule that recurs as long as the predicate evaluates to true.
    ///
    /// - Parameter f: Predicate to test the input.
    public static func doWhile(_ f: @escaping (A) -> Bool) -> Schedule<R, A, Unit, A> {
        doWhileM { a in EnvIO.pure(f(a))^ }
    }
    
    /// Provides a schedule that recurs as long as the effectful predicate evaluates to true.
    ///
    /// - Parameter f: Effectful predicate to test the input.
    public static func doWhileM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, Unit, A> {
        identity().whileInputM(f)
    }
    
    /// Provides a schedule that recurs until the predicate evaluates to true.
    ///
    /// - Parameter f: Predicate to test the input.
    public static func doUntil(_ f: @escaping (A) -> Bool) -> Schedule<R, A, Unit, A> {
        doUntilM { a in EnvIO.pure(f(a))^ }
    }
    
    /// Provides a schedule that recurs until the effectful predicate evaluates to true.
    ///
    /// - Parameter f: Effectful predicate to test the input.
    public static func doUntilM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, Unit, A> {
        identity().untilInputM(f)
    }
    
    /// Provides a schedule that executes an effect for every consumed input.
    ///
    /// - Parameter f: Effectful function to run after every input.
    public static func tapInput(_ f: @escaping (A) -> EnvIO<R, Never, Void>) -> Schedule<R, A, Unit, A> {
        identity().tapInput(f)
    }
    
    /// Provides a schedule that executes an effect for every produced output.
    ///
    /// - Parameter f: Effectful function to run after every output.
    public static func tapOutput(_ f: @escaping (A) -> EnvIO<R, Never, Void>) -> Schedule<R, A, Unit, A> {
        identity().tapOutput(f)
    }
}

extension Schedule where State == Unit {
    /// Provides a schedule that recurs forever, mapping input values through the provided function.
    ///
    /// - Parameter function: Transforming function.
    public static func from(function: @escaping (A) -> B) -> Schedule<R, A, State, B> {
        Schedule<R, A, Unit, A>.identity().map(function)
    }
}

extension Schedule where A == B, State == Unit, A: Equatable {
    /// Provides a schedule that recurs as long as the input is equal to a specific value.
    ///
    /// - Parameter a: Value to compare the input of the schedule.
    public static func doWhileEquals(_ a: A) -> Schedule<R, A, Unit, A> {
        identity().whileInput { x in x == a }
    }
    
    /// Provides a schedule that recurs as long as the input is not equal to a specific value.
    ///
    /// - Parameter a: Value to compare the input of the schedule.
    public static func doUntilEquals(_ a: A) -> Schedule<R, A, Unit, A> {
        identity().untilInput { x in x == a }
    }
}

extension Schedule where B == Int, State == Int {
    /// Provides a schedule that runs forever and emits the number of iterations it has performed.
    public static func forever() -> Schedule<R, A, Int, Int> {
        Schedule<R, A, Int, Int>.unfold(0) { $0 + 1 }
    }
    
    /// Provides a schedule that recurs a specific number of times, emitting the current iteration it is in.
    ///
    /// - Parameter n: Number of iterations to perform.
    public static func recurs(_ n: Int) -> Schedule<R, A, Int, Int> {
        forever().whileOutput { $0 < n }
    }
    
    /// Provides a schedule that recurs only once.
    public static func once() -> Schedule<R, A, Int, Void> {
        recurs(1).void()
    }
    
    /// Provides a schedule that recurs zero times.
    public static func stop() -> Schedule<R, A, Int, Void> {
        recurs(0).void()
    }
}

extension Schedule where B == Never, A == Any, State == Never {
    /// Provides a schedule that never recurs.
    public static func never() -> Schedule<R, Any, Never, Never> {
        Schedule(
            initial: EnvIO.never()^,
            extract: { _, never in never },
            update: { _, _ in EnvIO.never()^ })
    }
}

extension Schedule where B == [A], State == (Unit, [A]) {
    /// Provides a schedule that recurs forever and collects all its outputs in an array.
    public static func collectAll() -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.identity().collectAll()
    }
    
    /// Provides a schedule that collects its outputs in an array as long as the outputs match a given predicate.
    ///
    /// - Parameter f: Predicate to test the outputs.
    public static func collectWhile(_ f: @escaping (A) -> Bool) -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.doWhile(f).collectAll()
    }
    
    /// Provides a schedule that collects its outputs in an array as long as the outputs match a given effectful predicate.
    ///
    /// - Parameter f: Effectful predicate to test the outputs.
    public static func collectWhileM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.doWhileM(f).collectAll()
    }
    
    /// Provides a schedule that collects its outputs in an array until an output matches a given predicate.
    ///
    /// - Parameter f: Predicate to test the outputs.
    public static func collectUntil(_ f: @escaping (A) -> Bool) -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.doUntil(f).collectAll()
    }
    
    /// Provides a schedule that collects its outputs in an array until an output matches a given effectful predicate.
    /// - Parameter f: Effectful predicate to test the outputs.
    public static func collectUntilM(_ f: @escaping (A) -> EnvIO<R, Never, Bool>) -> Schedule<R, A, State, [A]> {
        Schedule<R, A, Unit, A>.doUntilM(f).collectAll()
    }
}

extension Kleisli {
    func unitError<E: Error>() -> EnvIO<D, Unit, A> where F == IOPartial<E> {
        self.mapError { _ in .unit }
    }
}
