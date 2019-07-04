import Foundation
import Bow

public final class ForIO {}
public final class IOPartial<E: Error>: Kind<ForIO, E> {}
public typealias IOOf<E: Error, A> = Kind<IOPartial<E>, A>

public class IO<E: Error, A>: IOOf<E, A> {
    public static func fix(_ fa: IOOf<E, A>) -> IO<E, A> {
        return fa as! IO<E, A>
    }
    
    public static func invoke(_ f: @escaping () throws -> A) -> IO<E, A> {
        return IO.fix(IO.suspend({
            do {
                return Pure<E, A>(try f())
            } catch let error as E {
                return RaiseError(error)
            } catch {
                fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
            }
        }))
    }
    
    public static func merge<B>(_ fa : @escaping () throws -> A,
                                _ fb : @escaping () throws -> B) -> IO<E, (A, B)> {
        return IO<E, (A, B)>.fix(IO<E, (A, B)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb)))
    }
    
    public static func merge<B, C>(_ fa : @escaping () throws -> A,
                                   _ fb : @escaping () throws -> B,
                                   _ fc : @escaping () throws -> C) -> IO<E, (A, B, C)> {
        return IO<E, (A, B, C)>.fix(IO<E, (A, B, C)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc)))
    }
    
    public static func merge<B, C, D>(_ fa : @escaping () throws -> A,
                                      _ fb : @escaping () throws -> B,
                                      _ fc : @escaping () throws -> C,
                                      _ fd : @escaping () throws -> D) -> IO<E, (A, B, C, D)> {
        return IO<E, (A, B, C, D)>.fix(IO<E, (A, B, C, D)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd)))
    }
    
    public static func merge<B, C, D, F>(_ fa : @escaping () throws -> A,
                                         _ fb : @escaping () throws -> B,
                                         _ fc : @escaping () throws -> C,
                                         _ fd : @escaping () throws -> D,
                                         _ ff : @escaping () throws -> F) -> IO<E, (A, B, C, D, F)> {
        return IO<E, (A, B, C, D, F)>.fix(IO<E, (A, B, C, D, F)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff)))
    }
    
    public static func merge<B, C, D, F, G>(_ fa : @escaping () throws -> A,
                                            _ fb : @escaping () throws -> B,
                                            _ fc : @escaping () throws -> C,
                                            _ fd : @escaping () throws -> D,
                                            _ ff : @escaping () throws -> F,
                                            _ fg : @escaping () throws -> G) -> IO<E, (A, B, C, D, F, G)> {
        return IO<E, (A, B, C, D, F, G)>.fix(IO<E, (A, B, C, D, F, G)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg)))
    }
    
    public static func merge<B, C, D, F, G, H>(_ fa : @escaping () throws -> A,
                                               _ fb : @escaping () throws -> B,
                                               _ fc : @escaping () throws -> C,
                                               _ fd : @escaping () throws -> D,
                                               _ ff : @escaping () throws -> F,
                                               _ fg : @escaping () throws -> G,
                                               _ fh : @escaping () throws -> H ) -> IO<E, (A, B, C, D, F, G, H)> {
        return IO<E, (A, B, C, D, F, G, H)>.fix(IO<E, (A, B, C, D, F, G, H)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh)))
    }
    
    public static func merge<B, C, D, F, G, H, I>(_ fa : @escaping () throws -> A,
                                                  _ fb : @escaping () throws -> B,
                                                  _ fc : @escaping () throws -> C,
                                                  _ fd : @escaping () throws -> D,
                                                  _ ff : @escaping () throws -> F,
                                                  _ fg : @escaping () throws -> G,
                                                  _ fh : @escaping () throws -> H,
                                                  _ fi : @escaping () throws -> I) -> IO<E, (A, B, C, D, F, G, H, I)> {
        return IO<E, (A, B, C, D, F, G, H, I)>.fix(IO<E, (A, B, C, D, F, G, H, I)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh),
            IO<E, I>.invoke(fi)))
    }
    
    public static func merge<B, C, D, F, G, H, I, J>(_ fa : @escaping () throws -> A,
                                                     _ fb : @escaping () throws -> B,
                                                     _ fc : @escaping () throws -> C,
                                                     _ fd : @escaping () throws -> D,
                                                     _ ff : @escaping () throws -> F,
                                                     _ fg : @escaping () throws -> G,
                                                     _ fh : @escaping () throws -> H,
                                                     _ fi : @escaping () throws -> I,
                                                     _ fj : @escaping () throws -> J ) -> IO<E, (A, B, C, D, F, G, H, I, J)> {
        return IO<E, (A, B, C, D, F, G, H, I, J)>.fix(IO<E, (A, B, C, D, F, G, H, I, J)>.tupled(
            IO<E, A>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh),
            IO<E, I>.invoke(fi),
            IO<E, J>.invoke(fj)))
    }
    
    public func unsafePerformIO(on queue: DispatchQueue = .main) throws -> A {
        return try self._unsafePerformIO(on: queue).0
    }
    
    internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        fatalError("_unsafePerformIO must be implemented in subclasses")
    }
    
    internal func on<T>(queue: DispatchQueue, perform: @escaping () throws -> T) throws -> T {
        if DispatchQueue.currentLabel == queue.label {
            return try perform()
        } else {
            return try queue.sync {
                try perform()
            }
        }
    }
    
    public func attempt(on queue: DispatchQueue = .main) -> IO<E, A>{
        do {
            let result = try self.unsafePerformIO(on: queue)
            return IO.pure(result)^
        } catch let error as E {
            return IO.raiseError(error)^
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
        }
    }
    
    public func unsafeRunAsync(on queue: DispatchQueue = .main, _ callback: Callback<E, A>) {
        do {
            callback(Either.right(try unsafePerformIO(on: queue)))
        } catch let error as E {
            callback(Either.left(error))
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
        }
    }
    
    public func mapLeft<EE>(_ f: @escaping (E) -> EE) -> IO<EE, A> {
        return FErrorMap(f, self)
    }
    
    internal func description() -> String {
        return ""
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to IO.
public postfix func ^<E, A>(_ fa: IOOf<E, A>) -> IO<E, A> {
    return IO.fix(fa)
}

internal class Pure<E: Error, A>: IO<E, A> {
    let a: A
    
    init(_ a: A) {
        self.a = a
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return (try on(queue: queue) { self.a }, queue)
    }
    
    override internal func description() -> String {
        return "Pure(\(a))"
    }
}

internal class RaiseError<E: Error, A> : IO<E, A> {
    let error: E
    
    init(_ error : E) {
        self.error = error
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return (try on(queue: queue) { throw self.error }, queue)
    }
    
    override internal func description() -> String {
        return "RaiseError(\(error))"
    }
}

internal class FMap<E: Error, A, B> : IO<E, B> {
    let f: (A) -> B
    let action: IO<E, A>
    
    init(_ f: @escaping (A) -> B, _ action: IO<E, A>) {
        self.f = f
        self.action = action
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (B, DispatchQueue) {
        let result = try action._unsafePerformIO(on: queue)
        return (try on(queue: result.1) { self.f(result.0) }, result.1)
    }
    
    override internal func description() -> String {
        return "FMap(\(action.description()))"
    }
}

internal class FErrorMap<E: Error, A, EE: Error>: IO<EE, A> {
    let f: (E) -> EE
    let action: IO<E, A>
    
    init(_ f: @escaping (E) -> EE, _ action: IO<E, A>) {
        self.f = f
        self.action = action
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        do {
            return try action._unsafePerformIO(on: queue)
        } catch let error as E {
            return (try on(queue: queue) { throw self.f(error) }, queue)
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
        }
    }
    
    override internal func description() -> String {
        return "FErrorMap(\(action.description()))"
    }
}

internal class Join<E: Error, A> : IO<E, A> {
    let io: IO<E, IO<E, A>>
    
    init(_ io: IO<E, IO<E, A>>) {
        self.io = io
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        let result = try io._unsafePerformIO(on: queue)
        return try result.0._unsafePerformIO(on: result.1)
    }
    
    override internal func description() -> String {
        return "Join(\(io.description()))"
    }
}

internal class AsyncIO<E: Error, A>: IO<E, A> {
    let f: ProcF<IOPartial<E>, E, A>
    
    init(_ f: @escaping ProcF<IOPartial<E>, E, A>) {
        self.f = f
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        var result: Either<E, A>?
        let group = DispatchGroup()
        group.enter()
        let callback: Callback<E, A> = { either in
            result = either
            group.leave()
        }
        let io = try on(queue: queue) {
            self.f(callback)
        }
        let procResult = try io^._unsafePerformIO(on: queue)
        group.wait()
        
        return (try IO.fromEither(result!)^._unsafePerformIO(on: procResult.1).0 , procResult.1)
    }
    
    override internal func description() -> String {
        return "Async"
    }
}

internal class ContinueOn<E: Error, A>: IO<E, A> {
    let io: IO<E, A>
    let queue: DispatchQueue
    
    init(_ io: IO<E, A>, _ queue: DispatchQueue) {
        self.io = io
        self.queue = queue
    }
    
    override internal func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return (try io._unsafePerformIO(on: queue).0, self.queue)
    }
}

internal class BracketIO<E: Error, A, B>: IO<E, B> {
    let io: IO<E, A>
    let release: (A, ExitCase<E>) -> Kind<IOPartial<E>, ()>
    let use: (A) throws -> Kind<IOPartial<E>, B>
    
    init(_ io: IO<E, A>,
         _ release: @escaping (A, ExitCase<E>) -> Kind<IOPartial<E>, ()>,
         _ use: @escaping (A) throws -> Kind<IOPartial<E>, B>) {
        self.io = io
        self.release = release
        self.use = use
    }
    
    override func _unsafePerformIO(on queue: DispatchQueue = .main) throws -> (B, DispatchQueue) {
        let ioResult = try io._unsafePerformIO(on: queue)
        let resource = ioResult.0
        do {
            let useResult = try use(resource)^._unsafePerformIO(on: queue)
            let _ = try release(resource, .completed)^._unsafePerformIO(on: queue)
            return useResult
        } catch let error as E {
            let _ = try release(resource, .error(error))^._unsafePerformIO(on: queue)
            throw error
        } catch {
            fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
        }
    }
}

extension IOPartial: Functor {
    public static func map<A, B>(_ fa: Kind<IOPartial<E>, A>, _ f: @escaping (A) -> B) -> Kind<IOPartial<E>, B> {
        return FMap(f, IO.fix(fa))
    }
}

extension IOPartial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<IOPartial<E>, A> {
        return Pure(a)
    }
}

// MARK: Instance of `Selective` for `IO`
extension IOPartial: Selective {}

extension IOPartial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<IOPartial<E>, A>, _ f: @escaping (A) -> Kind<IOPartial<E>, B>) -> Kind<IOPartial<E>, B> {
        return Join(IO.fix(IO.fix(fa).map { x in IO.fix(f(x)) }))
    }
    
    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<IOPartial<E>, Either<A, B>>) -> Kind<IOPartial<E>, B> {
        return IO.fix(f(a)).flatMap { either in
            either.fold({ a in tailRecM(a, f) },
                        { b in IO.pure(b) })
        }
    }
}

extension IOPartial: ApplicativeError {
    public static func raiseError<A>(_ e: E) -> Kind<IOPartial<E>, A> {
        return RaiseError(e)
    }
    
    private static func fold<A, B>(_ io: IO<E, A>, _ fe: @escaping (E) -> B, _ fa: @escaping (A) -> B) -> B {
        switch io {
        case let pure as Pure<E, A>: return fa(pure.a)
        case let raise as RaiseError<E, A>: return fe(raise.error)
        default: fatalError("Invoke attempt before fold")
        }
    }
    
    public static func handleErrorWith<A>(_ fa: Kind<IOPartial<E>, A>, _ f: @escaping (E) -> Kind<IOPartial<E>, A>) -> Kind<IOPartial<E>, A> {
        return fold(IO.fix(fa).attempt(), f, IO.pure)
    }
}

extension IOPartial: MonadError {}

extension IOPartial: Bracket {
    public static func bracketCase<A, B>(_ fa: Kind<IOPartial<E>, A>, _ release: @escaping (A, ExitCase<E>) -> Kind<IOPartial<E>, ()>, _ use: @escaping (A) throws -> Kind<IOPartial<E>, B>) -> Kind<IOPartial<E>, B> {
        return BracketIO<E, A, B>(fa^, release, use)
    }
}

extension IOPartial: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> Kind<IOPartial<E>, A>) -> Kind<IOPartial<E>, A> {
        return Pure(()).flatMap(fa)
    }
}

extension IOPartial: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<E, A>) -> ()) -> Kind<IOPartial<E>, ()>) -> Kind<IOPartial<E>, A> {
        return AsyncIO(procf)
    }
    
    public static func continueOn<A>(_ fa: Kind<IOPartial<E>, A>, _ queue: DispatchQueue) -> Kind<IOPartial<E>, A> {
        return ContinueOn(fa^, queue)
    }
}

extension IOPartial: Concurrent {
    public static func asyncF<A>(_ fa: @escaping (KindConnection<IOPartial<E>>, @escaping (Either<E, A>) -> ()) -> Kind<IOPartial<E>, ()>) -> Kind<IOPartial<E>, A> {
        fatalError("TODO: Implement this")
    }
    
    public static func startFiber<A>(_ fa: Kind<IOPartial<E>, A>, _ queue: DispatchQueue) -> Kind<IOPartial<E>, Fiber<IOPartial<E>, A>> {
        fatalError("TODO: Implement this")
    }
    
    public static func racePair<A, B>(_ fa: Kind<IOPartial<E>, A>, _ fb: Kind<IOPartial<E>, B>, _ queue: DispatchQueue) -> Kind<IOPartial<E>, Either<(A, Fiber<IOPartial<E>, B>), (Fiber<IOPartial<E>, A>, B)>> {
        fatalError("TODO: Implement this")
    }
    
    public static func raceTriple<A, B, C>(_ fa: Kind<IOPartial<E>, A>, _ fb: Kind<IOPartial<E>, B>, _ fc: Kind<IOPartial<E>, C>, _ queue: DispatchQueue) -> Kind<IOPartial<E>, Either<(A, Fiber<IOPartial<E>, B>, Fiber<IOPartial<E>, C>), Either<(Fiber<IOPartial<E>, A>, B, Fiber<IOPartial<E>, C>), (Fiber<IOPartial<E>, A>, Fiber<IOPartial<E>, B>, C)>>> {
        fatalError("TODO: Implement this")
    }
}

extension IOPartial: Effect {
    public static func runAsync<A>(_ fa: Kind<IOPartial<E>, A>, _ callback: @escaping (Either<E, A>) -> Kind<IOPartial<E>, ()>) -> Kind<IOPartial<E>, ()> {
        fatalError("TODO: Implement this")
    }
}

extension IOPartial: ConcurrentEffect {
    public static func runAsyncCancellable<A>(_ fa: Kind<IOPartial<E>, A>, _ callback: @escaping (Either<E, A>) -> Kind<IOPartial<E>, ()>) -> Kind<IOPartial<E>, Disposable> {
        fatalError("TODO: Implement this")
    }
}

extension IOPartial: UnsafeRun {
    public static func runBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<IOPartial<E>, A>) throws -> A {
        return try fa()^.unsafePerformIO(on: queue)
    }
    
    public static func runNonBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<IOPartial<E>, A>, _ callback: (Either<E, A>) -> ()) {
        fa()^.unsafeRunAsync(on: queue, callback)
    }
}

extension IOPartial: EquatableK where E: Equatable {
    public static func eq<A: Equatable>(_ lhs: Kind<IOPartial<E>, A>, _ rhs: Kind<IOPartial<E>, A>) -> Bool {
        var aValue, bValue : A?
        var aError, bError : E?
        
        do {
            aValue = try IO.fix(lhs).unsafePerformIO()
        } catch let error as E {
            aError = error
        } catch {
            fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
        }
        
        do {
            bValue = try IO.fix(rhs).unsafePerformIO()
        } catch let error as E {
            bError = error
        } catch {
            fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
        }
        
        if let aV = aValue, let bV = bValue {
            return aV == bV
        } else if let aE = aError, let bE = bError {
            return aE == bE
        } else {
            return false
        }
    }
}
