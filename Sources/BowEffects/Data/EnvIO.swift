import Bow
import Foundation

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

public extension Kleisli where A == Void {
    static func sleep<E: Error>(_ interval: DispatchTimeInterval) -> EnvIO<D, E, Void> where F == IOPartial<E> {
        EnvIO { _ in IO.sleep(interval) }
    }
    
    static func sleep<E: Error>(_ interval: TimeInterval) -> EnvIO<D, E, Void> where F == IOPartial<E> {
        EnvIO { _ in IO.sleep(interval) }
    }
}

// MARK: Instance of `MonadDefer` for `Kleisli`

extension KleisliPartial: MonadDefer where F: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> Kind<KleisliPartial<F, D>, A>) -> Kind<KleisliPartial<F, D>, A> {
        Kleisli { d in F.defer { fa()^.invoke(d) } }
    }
}

// MARK: Instance of `Async` for `Kleisli`

extension KleisliPartial: Async where F: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<F.E, A>) -> ()) -> Kind<KleisliPartial<F, D>, ()>) -> Kind<KleisliPartial<F, D>, A> {
        Kleisli { d in
            F.asyncF { callback in
                procf(callback)^.invoke(d)
            }
        }
    }
    
    public static func continueOn<A>(_ fa: Kind<KleisliPartial<F, D>, A>, _ queue: DispatchQueue) -> Kind<KleisliPartial<F, D>, A> {
        Kleisli { d in
            fa^.invoke(d).continueOn(queue)
        }
    }
}

// MARK: Instance of `Concurrent` for `Kleisli`

extension KleisliPartial: Concurrent where F: Concurrent {
    public static func race<A, B>(_ fa: Kind<KleisliPartial<F, D>, A>, _ fb: Kind<KleisliPartial<F, D>, B>) -> Kind<KleisliPartial<F, D>, Either<A, B>> {
        Kleisli { d in
            F.race(fa^.invoke(d), fb^.invoke(d))
        }
    }
    
    public static func parMap<A, B, Z>(_ fa: Kind<KleisliPartial<F, D>, A>, _ fb: Kind<KleisliPartial<F, D>, B>, _ f: @escaping (A, B) -> Z) -> Kind<KleisliPartial<F, D>, Z> {
        Kleisli { d in
            F.parMap(fa^.invoke(d), fb^.invoke(d), f)
        }
    }
    
    public static func parMap<A, B, C, Z>(_ fa: Kind<KleisliPartial<F, D>, A>, _ fb: Kind<KleisliPartial<F, D>, B>, _ fc: Kind<KleisliPartial<F, D>, C>, _ f: @escaping (A, B, C) -> Z) -> Kind<KleisliPartial<F, D>, Z> {
        Kleisli { d in
            F.parMap(fa^.invoke(d), fb^.invoke(d), fc^.invoke(d), f)
        }
    }
}
