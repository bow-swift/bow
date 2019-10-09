import Foundation
import Bow

/// Witness for the `IO<E, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForIO {}

/// Partial application of the `IO` type constructor, omitting the last parameters.
public final class IOPartial<E: Error>: Kind<ForIO, E> {}

/// Higher Kinded Type alias to improve readability over `Kind<IOPartial<E>, A>`.
public typealias IOOf<E: Error, A> = Kind<IOPartial<E>, A>

/// Witness for the `Task<A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForTask = IOPartial<Error>

/// A Task is an IO with no explicit error type, resorting to the `Error` protocol to handle them.
public typealias Task<A> = IO<Error, A>

/// Witness for the `UIO<A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForUIO = IOPartial<Never>

/// An UIO is an IO operation that never fails; i.e. it never produces errors.
public typealias UIO<A> = IO<Never, A>

/// Partial application of the `EnvIO` type constructor, omitting the last type parameter.
public typealias EnvIOPartial<D, E: Error> = KleisliPartial<IOPartial<E>, D>

/// EnvIO is a data type to perform IO operations that produce errors of type `E` and values of type `A`, having access to an immutable environment of type `D`. It can be seen as a Kleisli function `(D) -> IO<E, A>`.
public typealias EnvIO<D, E: Error, A> = Kleisli<IOPartial<E>, D, A>

/// Partial application of the EnvIO data type, omitting the last parameter.
public typealias RIOPartial<D> = EnvIOPartial<D, Error>

/// A RIO is a data type like EnvIO with no explicit error type, resorting to the `Error` protocol to handle them.
public typealias RIO<D, A> = EnvIO<D, Error, A>

/// Partial application of the URIO data type, omitting the last parameter.
public typealias URIOPartial<D> = EnvIOPartial<D, Never>

/// An URIO is a data type like EnvIO that never fails; i.e. it never produces errors.
public typealias URIO<D, A> = EnvIO<D, Never, A>

/// Models errors that can happen during IO evaluation.
///
/// - timeout: The evaluation of the IO produced a timeout.
public enum IOError: Error {
    case timeout
}

/// An IO is a data type that encapsulates and suspends side effects producing values of type `A` or errors of type `E`.
public class IO<E: Error, A>: IOOf<E, A> {
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in higher-kind form.
    /// - Returns: Value casted to IO.
    public static func fix(_ fa: IOOf<E, A>) -> IO<E, A> {
        return fa as! IO<E, A>
    }
    
    /// Creates an IO from a side-effectful function.
    ///
    /// - Parameter f: Side-effectful function. Errors thrown from this function must be of type `E`; otherwise, a fatal error will happen.
    /// - Returns: An IO function suspending the execution of the side effect.
    public static func invoke(_ f: @escaping () throws -> A) -> IO<E, A> {
        return IO.defer {
            do {
                return Pure<E, A>(try f())
            } catch let error as E {
                return RaiseError(error)
            } catch {
                fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
            }
        }^
    }
    
    /// Creates an IO from a side-effectful function.
    ///
    /// - Parameter f: Side-effectful function returning an `Either`. Errors thrown from this function must be of type `E`; otherwise, a fatal error will happen.
    /// - Returns: An IO suspending the execution of the side effect.
    public static func invokeEither(_ f: @escaping () throws -> Either<E, A>) -> IO<E, A> {
        return IO.defer {
            do {
                return try f().fold(IO.raiseError, IO.pure)
            } catch let error as E {
                return raiseError(error)
            } catch {
                fatalError("IO did not handle error \(error). Only errors of type \(E.self) are handled.")
            }
        }^
    }
    
    /// Creates an IO from a side-effectful function.
    ///
    /// - Parameter f: Side-effectful function returning a `Result`. Errors thrown from this function must be of type `E`; otherwise, a fatal error will happen.
    /// - Returns: An IO suspending the execution of the side effect.
    public static func invokeResult(_ f: @escaping () throws -> Result<A, E>) -> IO<E, A> {
        return invokeEither { try f().toEither() }
    }
    
    /// Creates an IO from a side-effectful function.
    ///
    /// - Parameter f: Side-effectful function returning an `Validated`. Errors thrown from this function must be of type `E`; otherwise, a fatal error will happen.
    /// - Returns: An IO suspending the execution of the side effect.
    public static func invokeValidated(_ f: @escaping () throws -> Validated<E, A>) -> IO<E, A> {
        return invokeEither { try f().toEither() }
    }
    
    /// Creates an IO from 2 side-effectful functions, tupling their results. Errors thrown from the functions must be of type `E`; otherwise, a fatal error will happen.
    ///
    /// - Parameters:
    ///   - fa: 1st side-effectful function.
    ///   - fb: 2nd side-effectful function.
    /// - Returns: An IO suspending the execution of the side effects.
    public static func merge<Z, B>(_ fa: @escaping () throws -> Z,
                                   _ fb: @escaping () throws -> B) -> IO<E, (Z, B)> where A == (Z, B) {
        return IO.zip(
            IO<E, Z>.invoke(fa),
            IO<E, B>.invoke(fb))^
    }
    
    /// Creates an IO from 3 side-effectful functions, tupling their results. Errors thrown from the functions must be of type `E`; otherwise, a fatal error will happen.
    ///
    /// - Parameters:
    ///   - fa: 1st side-effectful function.
    ///   - fb: 2nd side-effectful function.
    ///   - fc: 3rd side-effectful function.
    /// - Returns: An IO suspending the execution of the side effects.
    public static func merge<Z, B, C>(_ fa: @escaping () throws -> Z,
                                      _ fb: @escaping () throws -> B,
                                      _ fc: @escaping () throws -> C) -> IO<E, (Z, B, C)> where A == (Z, B, C) {
        return IO.zip(
            IO<E, Z>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc))^
    }
    
    /// Creates an IO from 4 side-effectful functions, tupling their results. Errors thrown from the functions must be of type `E`; otherwise, a fatal error will happen.
    ///
    /// - Parameters:
    ///   - fa: 1st side-effectful function.
    ///   - fb: 2nd side-effectful function.
    ///   - fc: 3rd side-effectful function.
    ///   - fd: 4th side-effectful function.
    /// - Returns: An IO suspending the execution of the side effects.
    public static func merge<Z, B, C, D>(_ fa: @escaping () throws -> Z,
                                         _ fb: @escaping () throws -> B,
                                         _ fc: @escaping () throws -> C,
                                         _ fd: @escaping () throws -> D) -> IO<E, (Z, B, C, D)> where A == (Z, B, C, D) {
        return IO.zip(
            IO<E, Z>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd))^
    }
    
    /// Creates an IO from 5 side-effectful functions, tupling their results. Errors thrown from the functions must be of type `E`; otherwise, a fatal error will happen.
    ///
    /// - Parameters:
    ///   - fa: 1st side-effectful function.
    ///   - fb: 2nd side-effectful function.
    ///   - fc: 3rd side-effectful function.
    ///   - fd: 4th side-effectful function.
    ///   - ff: 5th side-effectful function.
    /// - Returns: An IO suspending the execution of the side effects.
    public static func merge<Z, B, C, D, F>(_ fa: @escaping () throws -> Z,
                                            _ fb: @escaping () throws -> B,
                                            _ fc: @escaping () throws -> C,
                                            _ fd: @escaping () throws -> D,
                                            _ ff: @escaping () throws -> F) -> IO<E, (Z, B, C, D, F)> where A == (Z, B, C, D, F) {
        return IO.zip(
            IO<E, Z>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff))^
    }
    
    /// Creates an IO from 6 side-effectful functions, tupling their results. Errors thrown from the functions must be of type `E`; otherwise, a fatal error will happen.
    ///
    /// - Parameters:
    ///   - fa: 1st side-effectful function.
    ///   - fb: 2nd side-effectful function.
    ///   - fc: 3rd side-effectful function.
    ///   - fd: 4th side-effectful function.
    ///   - ff: 5th side-effectful function.
    ///   - fg: 6th side-effectful function.
    /// - Returns: An IO suspending the execution of the side effects.
    public static func merge<Z, B, C, D, F, G>(_ fa: @escaping () throws -> Z,
                                               _ fb: @escaping () throws -> B,
                                               _ fc: @escaping () throws -> C,
                                               _ fd: @escaping () throws -> D,
                                               _ ff: @escaping () throws -> F,
                                               _ fg: @escaping () throws -> G) -> IO<E, (Z, B, C, D, F, G)> where A == (Z, B, C, D, F, G){
        return IO.zip(
            IO<E, Z>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg))^
    }
    
    /// Creates an IO from 7 side-effectful functions, tupling their results. Errors thrown from the functions must be of type `E`; otherwise, a fatal error will happen.
    ///
    /// - Parameters:
    ///   - fa: 1st side-effectful function.
    ///   - fb: 2nd side-effectful function.
    ///   - fc: 3rd side-effectful function.
    ///   - fd: 4th side-effectful function.
    ///   - ff: 5th side-effectful function.
    ///   - fg: 6th side-effectful function.
    ///   - fh: 7th side-effectful function.
    /// - Returns: An IO suspending the execution of the side effects.
    public static func merge<Z, B, C, D, F, G, H>(_ fa: @escaping () throws -> Z,
                                                  _ fb: @escaping () throws -> B,
                                                  _ fc: @escaping () throws -> C,
                                                  _ fd: @escaping () throws -> D,
                                                  _ ff: @escaping () throws -> F,
                                                  _ fg: @escaping () throws -> G,
                                                  _ fh: @escaping () throws -> H ) -> IO<E, (Z, B, C, D, F, G, H)> where A == (Z, B, C, D, F, G, H) {
        return IO.zip(
            IO<E, Z>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh))^
    }
    
    /// Creates an IO from 8 side-effectful functions, tupling their results. Errors thrown from the functions must be of type `E`; otherwise, a fatal error will happen.
    ///
    /// - Parameters:
    ///   - fa: 1st side-effectful function.
    ///   - fb: 2nd side-effectful function.
    ///   - fc: 3rd side-effectful function.
    ///   - fd: 4th side-effectful function.
    ///   - ff: 5th side-effectful function.
    ///   - fg: 6th side-effectful function.
    ///   - fh: 7th side-effectful function.
    ///   - fi: 8th side-effectful function.
    /// - Returns: An IO suspending the execution of the side effects.
    public static func merge<Z, B, C, D, F, G, H, I>(_ fa: @escaping () throws -> Z,
                                                     _ fb: @escaping () throws -> B,
                                                     _ fc: @escaping () throws -> C,
                                                     _ fd: @escaping () throws -> D,
                                                     _ ff: @escaping () throws -> F,
                                                     _ fg: @escaping () throws -> G,
                                                     _ fh: @escaping () throws -> H,
                                                     _ fi: @escaping () throws -> I) -> IO<E, (Z, B, C, D, F, G, H, I)> where A == (Z, B, C, D, F, G, H, I) {
        return IO.zip(
            IO<E, Z>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh),
            IO<E, I>.invoke(fi))^
    }
    
    /// Creates an IO from 9 side-effectful functions, tupling their results. Errors thrown from the functions must be of type `E`; otherwise, a fatal error will happen.
    ///
    /// - Parameters:
    ///   - fa: 1st side-effectful function.
    ///   - fb: 2nd side-effectful function.
    ///   - fc: 3rd side-effectful function.
    ///   - fd: 4th side-effectful function.
    ///   - ff: 5th side-effectful function.
    ///   - fg: 6th side-effectful function.
    ///   - fh: 7th side-effectful function.
    ///   - fi: 8th side-effectful function.
    ///   - fj: 9th side-effectful function.
    /// - Returns: An IO suspending the execution of the side effects.
    public static func merge<Z, B, C, D, F, G, H, I, J>(_ fa: @escaping () throws -> Z,
                                                        _ fb: @escaping () throws -> B,
                                                        _ fc: @escaping () throws -> C,
                                                        _ fd: @escaping () throws -> D,
                                                        _ ff: @escaping () throws -> F,
                                                        _ fg: @escaping () throws -> G,
                                                        _ fh: @escaping () throws -> H,
                                                        _ fi: @escaping () throws -> I,
                                                        _ fj: @escaping () throws -> J ) -> IO<E, (Z, B, C, D, F, G, H, I, J)> where A == (Z, B, C, D, F, G, H, I, J) {
        return IO.zip(
            IO<E, Z>.invoke(fa),
            IO<E, B>.invoke(fb),
            IO<E, C>.invoke(fc),
            IO<E, D>.invoke(fd),
            IO<E, F>.invoke(ff),
            IO<E, G>.invoke(fg),
            IO<E, H>.invoke(fh),
            IO<E, I>.invoke(fi),
            IO<E, J>.invoke(fj))^
    }
    
    /// Performs the side effects that are suspended in this IO in a synchronous manner.
    ///
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: Value produced after running the suspended side effects.
    /// - Throws: Error of type `E` that may happen during the evaluation of the side-effects. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    public func unsafeRunSync(on queue: DispatchQueue = .main) throws -> A {
        return try self._unsafeRunSync(on: queue).0
    }
    
    /// Performs the side effects that are suspended in this IO in a synchronous manner.
    ///
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: An Either wrapping errors in the left side and values on the right side. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    public func unsafeRunSyncEither(on queue: DispatchQueue = .main) -> Either<E, A> {
        do {
            return .right(try self.unsafeRunSync())
        } catch let e as E {
            return .left(e)
        } catch {
            fail(error)
        }
    }
    
    internal func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        fatalError("_unsafeRunSync must be implemented in subclasses")
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
    
    /// Flattens the internal structure of this IO by performing the side effects and wrapping them again in an IO structure containing the result or the error produced.
    ///
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: An IO that either contains the value produced or an error. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    public func attempt(on queue: DispatchQueue = .main) -> IO<E, A>{
        do {
            let result = try self.unsafeRunSync(on: queue)
            return IO.pure(result)^
        } catch let error as E {
            return IO.raiseError(error)^
        } catch {
            fail(error)
        }
    }
    
    /// Performs the side effects that are suspended in this IO in an asynchronous manner.
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    ///   - callback: A callback function to receive the results of the evaluation. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    public func unsafeRunAsync(on queue: DispatchQueue = .main, _ callback: @escaping Callback<E, A>) {
        queue.async {
            do {
                callback(Either.right(try self.unsafeRunSync(on: queue)))
            } catch let error as E {
                callback(Either.left(error))
            } catch {
                self.fail(error)
            }
        }
    }
    
    /// Transforms the error type of this IO.
    ///
    /// - Parameter f: Function transforming the error.
    /// - Returns: An IO value with the new error type.
    public func mapLeft<EE>(_ f: @escaping (E) -> EE) -> IO<EE, A> {
        return FErrorMap(f, self)
    }
    
    /// Returns this `IO` erasing the error type information
    public var anyError: IO<Error, A> {
        return self.mapLeft { e in e as Error }
    }
    
    internal func fail(_ error: Error) -> Never {
        fatalError("IO did not handle error: \(error). Only errors of type \(E.self) are handled.")
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to IO.
public postfix func ^<E, A>(_ fa: IOOf<E, A>) -> IO<E, A> {
    return IO.fix(fa)
}

// MARK: Functions for Task

public extension IO where E == Error {
    /// Creates an IO from a side-effectful function.
    ///
    /// - Parameter f: Side-effectful function returning a `Try`. Errors thrown from this function must be of type `E`; otherwise, a fatal error will happen.
    /// - Returns: An IO suspending the execution of the side effect.
    static func invokeTry(_ f: @escaping () throws -> Try<A>) -> IO<Error, A> {
        return invokeEither { try f().toEither() }
    }
}

// MARK: Functions for EnvIO

public extension Kleisli {
    /// Transforms the error type of this EnvIO
    ///
    /// - Parameter f: Function transforming the error.
    /// - Returns: An EnvIO value with the new error type.
    func mapError<E: Error, EE: Error>(_ f: @escaping (E) -> EE) -> EnvIO<D, EE, A> where F == IOPartial<E> {
        return EnvIO { env in self.invoke(env)^.mapLeft(f) }
    }
    
    /// Provides the required environment.
    ///
    /// - Parameter d: Environment.
    /// - Returns: An IO resulting from running this computation with the provided environment.
    func provide<E: Error>(_ d: D) -> IO<E, A> where F == IOPartial<E> {
        return self.invoke(d)^
    }
    
    /// Performs the side effects that are suspended in this IO in a synchronous manner.
    ///
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: Value produced after running the suspended side effects.
    /// - Throws: Error of type `E` that may happen during the evaluation of the side-effects. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunSync<E: Error>(on queue: DispatchQueue = .main) throws -> A where D == Any, F == IOPartial<E> {
        try self.provide(()).unsafeRunSync(on: queue)
    }
    
    /// Performs the side effects that are suspended in this EnvIO in a synchronous manner.
    ///
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: An Either wrapping errors in the left side and values on the right side. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunSyncEither<E: Error>(on queue: DispatchQueue = .main) -> Either<E, A> where D == Any, F == IOPartial<E> {
        self.provide(()).unsafeRunSyncEither(on: queue)
    }
    
    /// Performs the side effects that are suspended in this EnvIO in an asynchronous manner.
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    ///   - callback: A callback function to receive the results of the evaluation. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunAsync<E: Error>(on queue: DispatchQueue = .main, _ callback: @escaping Callback<E, A>) where D == Any, F == IOPartial<E> {
        self.provide(()).unsafeRunAsync(on: queue, callback)
    }
}

internal class Pure<E: Error, A>: IO<E, A> {
    let a: A
    
    init(_ a: A) {
        self.a = a
    }
    
    override internal func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return (try on(queue: queue) { self.a }, queue)
    }
}

internal class RaiseError<E: Error, A> : IO<E, A> {
    let error: E
    
    init(_ error : E) {
        self.error = error
    }
    
    override internal func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return (try on(queue: queue) { throw self.error }, queue)
    }
}

internal class FMap<E: Error, A, B> : IO<E, B> {
    let f: (A) -> B
    let action: IO<E, A>
    
    init(_ f: @escaping (A) -> B, _ action: IO<E, A>) {
        self.f = f
        self.action = action
    }
    
    override internal func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (B, DispatchQueue) {
        let result = try action._unsafeRunSync(on: queue)
        return (try on(queue: result.1) { self.f(result.0) }, result.1)
    }
}

internal class FErrorMap<E: Error, A, EE: Error>: IO<EE, A> {
    let f: (E) -> EE
    let action: IO<E, A>
    
    init(_ f: @escaping (E) -> EE, _ action: IO<E, A>) {
        self.f = f
        self.action = action
    }
    
    override internal func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        do {
            return try action._unsafeRunSync(on: queue)
        } catch let error as E {
            return (try on(queue: queue) { throw self.f(error) }, queue)
        } catch {
            self.fail(error)
        }
    }
}

internal class Join<E: Error, A> : IO<E, A> {
    let io: IO<E, IO<E, A>>
    
    init(_ io: IO<E, IO<E, A>>) {
        self.io = io
    }
    
    override internal func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        let result = try io._unsafeRunSync(on: queue)
        return try result.0._unsafeRunSync(on: result.1)
    }
}

internal class AsyncIO<E: Error, A>: IO<E, A> {
    let f: ProcF<IOPartial<E>, E, A>
    
    init(_ f: @escaping ProcF<IOPartial<E>, E, A>) {
        self.f = f
    }
    
    override internal func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
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
        let procResult = try io^._unsafeRunSync(on: queue)
        group.wait()
        
        return (try IO.fromEither(result!)^._unsafeRunSync(on: procResult.1).0 , procResult.1)
    }
}

internal class ContinueOn<E: Error, A>: IO<E, A> {
    let io: IO<E, A>
    let queue: DispatchQueue
    
    init(_ io: IO<E, A>, _ queue: DispatchQueue) {
        self.io = io
        self.queue = queue
    }
    
    override internal func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return (try io._unsafeRunSync(on: queue).0, self.queue)
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
    
    override func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (B, DispatchQueue) {
        let ioResult = try io._unsafeRunSync(on: queue)
        let resource = ioResult.0
        do {
            let useResult = try use(resource)^._unsafeRunSync(on: queue)
            let _ = try release(resource, .completed)^._unsafeRunSync(on: queue)
            return useResult
        } catch let error as E {
            let _ = try release(resource, .error(error))^._unsafeRunSync(on: queue)
            throw error
        } catch {
            self.fail(error)
        }
    }
}

internal class ParMap2<E: Error, A, B, Z>: IO<E, Z> {
    private let fa: IO<E, A>
    private let fb: IO<E, B>
    private let f: (A, B) -> Z
    
    init(_ fa: IO<E, A>, _ fb: IO<E, B>, _ f: @escaping (A, B) -> Z) {
        self.fa = fa
        self.fb = fb
        self.f = f
    }
    
    override func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (Z, DispatchQueue) {
        var a: A?
        var b: B?
        let atomic = Atomic<E?>(nil)
        let group = DispatchGroup()
        let parQueue1 = DispatchQueue(label: queue.label + "parMap1", qos: queue.qos)
        let parQueue2 = DispatchQueue(label: queue.label + "parMap2", qos: queue.qos)
        
        group.enter()
        parQueue1.async {
            do {
                a = try self.fa._unsafeRunSync(on: parQueue1).0
            } catch let error as E {
                atomic.setIfNil(error)
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.enter()
        parQueue2.async {
            do {
                b = try self.fb._unsafeRunSync(on: parQueue2).0
            } catch let error as E {
                atomic.setIfNil(error)
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.wait()
        if let aa = a, let bb = b {
            return (f(aa, bb), queue)
        } else {
            throw atomic.value!
        }
    }
}

internal class ParMap3<E: Error, A, B, C, Z>: IO<E, Z> {
    private let fa: IO<E, A>
    private let fb: IO<E, B>
    private let fc: IO<E, C>
    private let f: (A, B, C) -> Z
    
    init(_ fa: IO<E, A>, _ fb: IO<E, B>, _ fc: IO<E, C>, _ f: @escaping (A, B, C) -> Z) {
        self.fa = fa
        self.fb = fb
        self.fc = fc
        self.f = f
    }
    
    override func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (Z, DispatchQueue) {
        var a: A?
        var b: B?
        var c: C?
        let atomic = Atomic<E?>(nil)
        let group = DispatchGroup()
        let parQueue1 = DispatchQueue(label: queue.label + "parMap1", qos: queue.qos)
        let parQueue2 = DispatchQueue(label: queue.label + "parMap2", qos: queue.qos)
        let parQueue3 = DispatchQueue(label: queue.label + "parMap3", qos: queue.qos)
        
        group.enter()
        parQueue1.async {
            do {
                a = try self.fa._unsafeRunSync(on: parQueue1).0
            } catch let error as E {
                atomic.value = error
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.enter()
        parQueue2.async {
            do {
                b = try self.fb._unsafeRunSync(on: parQueue2).0
            } catch let error as E {
                atomic.value = error
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.enter()
        parQueue3.async {
            do {
                c = try self.fc._unsafeRunSync(on: parQueue3).0
            } catch let error as E {
                atomic.value = error
            } catch {
                self.fail(error)
            }
            group.leave()
        }
        
        group.wait()
        if let aa = a, let bb = b, let cc = c {
            return (f(aa, bb, cc), queue)
        } else {
            throw atomic.value!
        }
    }
}

internal class IOEffect<E: Error, A>: IO<E, ()> {
    let io: IO<E, A>
    let callback: (Either<E, A>) -> IOOf<E, ()>
    
    init(_ io: IO<E, A>, _ callback: @escaping (Either<E, A>) -> IOOf<E, ()>) {
        self.io = io
        self.callback = callback
    }
    
    override func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> ((), DispatchQueue) {
        var result: IOOf<E, ()>
        do {
            let (a, nextQueue) = try io._unsafeRunSync(on: queue)
            result = callback(.right(a))
            return try result^._unsafeRunSync(on: nextQueue)
        } catch let error as E {
            result = callback(.left(error))
            return try result^._unsafeRunSync(on: queue)
        } catch {
            fail(error)
        }
    }
}

internal class Suspend<E: Error, A>: IO<E, A> {
    let thunk: () -> IOOf<E, A>
    
    init(_ thunk: @escaping () -> IOOf<E, A>) {
        self.thunk = thunk
    }
    
    override func _unsafeRunSync(on queue: DispatchQueue = .main) throws -> (A, DispatchQueue) {
        return try on(queue: queue) {
            try self.thunk()^._unsafeRunSync(on: queue)
        }
    }
}

// MARK: Instance of `Functor` for `IO`
extension IOPartial: Functor {
    public static func map<A, B>(_ fa: IOOf<E, A>, _ f: @escaping (A) -> B) -> IOOf<E, B> {
        return FMap(f, IO.fix(fa))
    }
}

// MARK: Instance of `Applicative` for `IO`
extension IOPartial: Applicative {
    public static func pure<A>(_ a: A) -> IOOf<E, A> {
        return Pure(a)
    }
}

// MARK: Instance of `Selective` for `IO`
extension IOPartial: Selective {}

// MARK: Instance of `Monad` for `IO`
extension IOPartial: Monad {
    public static func flatMap<A, B>(_ fa: IOOf<E, A>, _ f: @escaping (A) -> IOOf<E, B>) -> IOOf<E, B> {
        return Join(IO.fix(IO.fix(fa).map { x in IO.fix(f(x)) }))
    }
    
    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> IOOf<E, Either<A, B>>) -> IOOf<E, B> {
        return IO.fix(f(a)).flatMap { either in
            either.fold({ a in tailRecM(a, f) },
                        { b in IO.pure(b) })
        }
    }
}

// MARK: Instance of `ApplicativeError` for `IO`
extension IOPartial: ApplicativeError {
    public static func raiseError<A>(_ e: E) -> IOOf<E, A> {
        return RaiseError(e)
    }
    
    private static func fold<A, B>(_ io: IO<E, A>, _ fe: @escaping (E) -> B, _ fa: @escaping (A) -> B) -> B {
        switch io {
        case let pure as Pure<E, A>: return fa(pure.a)
        case let raise as RaiseError<E, A>: return fe(raise.error)
        default: fatalError("Invoke attempt before fold")
        }
    }
    
    public static func handleErrorWith<A>(_ fa: IOOf<E, A>, _ f: @escaping (E) -> IOOf<E, A>) -> IOOf<E, A> {
        return fold(IO.fix(fa).attempt(), f, IO.pure)
    }
}

// MARK: Instance of `MonadError` for `IO`
extension IOPartial: MonadError {}

// MARK: Instance of `Bracket` for `IO`
extension IOPartial: Bracket {
    public static func bracketCase<A, B>(acquire fa: IOOf<E, A>, release: @escaping (A, ExitCase<E>) -> IOOf<E, ()>, use: @escaping (A) throws -> IOOf<E, B>) -> IOOf<E, B> {
        return BracketIO<E, A, B>(fa^, release, use)
    }
}

// MARK: Instance of `MonadDefer` for `IO`
extension IOPartial: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> IOOf<E, A>) -> IOOf<E, A> {
        return Suspend(fa)
    }
}

// MARK: Instance of `Async` for `IO`
extension IOPartial: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<E, A>) -> ()) -> IOOf<E, ()>) -> IOOf<E, A> {
        return AsyncIO(procf)
    }
    
    public static func continueOn<A>(_ fa: IOOf<E, A>, _ queue: DispatchQueue) -> IOOf<E, A> {
        return ContinueOn(fa^, queue)
    }
}

// MARK: Instance of `Concurrent` for `IO`
extension IOPartial: Concurrent {
    public static func parMap<A, B, Z>(_ fa: Kind<IOPartial<E>, A>, _ fb: Kind<IOPartial<E>, B>, _ f: @escaping (A, B) -> Z) -> Kind<IOPartial<E>, Z> {
        return ParMap2<E, A, B, Z>(fa^, fb^, f)
    }
    
    public static func parMap<A, B, C, Z>(_ fa: Kind<IOPartial<E>, A>, _ fb: Kind<IOPartial<E>, B>, _ fc: Kind<IOPartial<E>, C>, _ f: @escaping (A, B, C) -> Z) -> Kind<IOPartial<E>, Z> {
        return ParMap3<E, A, B, C, Z>(fa^, fb^, fc^, f)
    }
}

// MARK: Instance of `Effect` for `IO`
extension IOPartial: Effect {
    public static func runAsync<A>(_ fa: IOOf<E, A>, _ callback: @escaping (Either<E, A>) -> IOOf<E, ()>) -> IOOf<E, ()> {
        return IOEffect(fa^, callback)
    }
}

// MARK: Instance of `UnsafeRun` for `IO`
extension IOPartial: UnsafeRun {
    public static func runBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<IOPartial<E>, A>) throws -> A {
        return try fa()^.unsafeRunSync(on: queue)
    }
    
    public static func runNonBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<IOPartial<E>, A>, _ callback: @escaping (Either<E, A>) -> ()) {
        fa()^.unsafeRunAsync(on: queue, callback)
    }
}
