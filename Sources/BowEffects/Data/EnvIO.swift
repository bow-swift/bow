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
    
    /// Folds over the result of this computation by accepting an effect to execute in case of error, and another one in the case of success.
    ///
    /// - Parameters:
    ///   - f: Function to run in case of error.
    ///   - g: Function to run in case of success.
    /// - Returns: A computation from the result of applying the provided functions to the result of this computation.
    func foldM<B, E: Error>(_ f: @escaping (E) -> EnvIO<D, E, B>, _ g: @escaping (A) -> EnvIO<D, E, B>) -> EnvIO<D, E, B> where F == IOPartial<E> {
        self.flatMap(g).handleErrorWith(f)^
    }
    
    /// Retries this computation if it fails based on the provided retrial policy.
    ///
    /// This computation will be at least executed once, and if it fails, it will be retried according to the policy.
    ///
    /// - Parameter policy: Retrial policy.
    /// - Returns: A computation that is retried based on the provided policy when it fails.
    func retry<S, O, E: Error>(_ policy: Schedule<D, E, S, O>) -> EnvIO<D, E, A> where F == IOPartial<E> {
        retry(policy, orElse: { e, _ in EnvIO.raiseError(e)^ })
            .map { x in x.merge() }^
    }
    
    /// Retries this computation if it fails based on the provided retrial policy, providing a default computation to handle failures after retrial.
    ///
    /// This computation will be at least executed once, and if it fails, it will be retried according to the policy.
    ///
    /// - Parameters:
    ///   - policy: Retrial policy.
    ///   - orElse: Function to handle errors after retrying.
    /// - Returns: A computation that is retried based on the provided policy when it fails.
    func retry<S, O, B, E: Error>(_ policy: Schedule<D, E, S, O>, orElse: @escaping (E, O) -> EnvIO<D, E, B>) -> EnvIO<D, E, Either<B, A>> where F == IOPartial<E> {
        func loop(_ state: S) -> EnvIO<D, E, Either<B, A>> {
            self.foldM(
                { err in
                    policy.update(err, state)
                        .mapError { _ in err }
                        .foldM({ _ in orElse(err, policy.extract(err, state)).map(Either<B, A>.left)^ },
                               loop)
                    
                },
                { a in EnvIO<D, E, Either<B, A>>.pure(.right(a))^ })
        }
        
        return policy.initial
            .mapError { x in x as! E }
            .flatMap(loop)^
    }
    
    /// Repeats this computation until the provided repeating policy completes, or until it fails.
    ///
    /// This computation will be at least executed once, and if it succeeds, it will be repeated additional times according to the policy.
    ///
    /// - Parameters:
    ///   - policy: Repeating policy.
    ///   - onUpdateError: A function providing an error in case the policy fails to update properly.
    /// - Returns: A computation that is repeated based on the provided policy when it succeeds.
    func `repeat`<S, O, E: Error>(_ policy: Schedule<D, A, S, O>, onUpdateError: @escaping () -> E) -> EnvIO<D, E, O> where F == IOPartial<E> {
        self.repeat(policy, onUpdateError: onUpdateError) { e, _ in
            EnvIO<D, E, O>.raiseError(e)^
        }.map { x in x.merge() }^
    }
    
    /// Repeats this computation until the provided repeating policy completes, or until it fails, with a function to handle potential failures.
    ///
    /// - Parameters:
    ///   - policy: Repeating policy.
    ///   - onUpdateError: A function providing an error in case the policy fails to update properly.
    ///   - orElse: A function to return a computation in case of error.
    /// - Returns: A computation that is repeated based on the provided policy when it succeeds.
    func `repeat`<S, O, B, E: Error>(_ policy: Schedule<D, A, S, O>, onUpdateError: @escaping () -> E, orElse: @escaping (E, O?) -> EnvIO<D, E, B>) -> EnvIO<D, E, Either<B, O>> where F == IOPartial<E> {
        func loop(_ last: A, _ state: S) -> EnvIO<D, E, Either<B, O>> {
            policy.update(last, state)
                .mapError { _ in onUpdateError() }
                .foldM(
                    { _ in EnvIO<D, E, Either<B, O>>.pure(.right(policy.extract(last, state)))^ },
                    { s in
                        self.foldM(
                            { e in orElse(e, policy.extract(last, state)).map(Either.left)^ },
                            { a in loop(a, s) })
                })
        }
        
        return self.foldM(
            { e in orElse(e, nil).map(Either.left)^ },
            { a in policy.initial
                .mapError { x in x as! E }
                .flatMap { s in loop(a, s) }^ })
    }
}

public extension Kleisli where D == Any {
    /// Performs the side effects that are suspended in this IO in a synchronous manner.
    ///
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: Value produced after running the suspended side effects.
    /// - Throws: Error of type `E` that may happen during the evaluation of the side-effects. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunSync<E: Error>(on queue: DispatchQueue = .main) throws -> A where F == IOPartial<E> {
        try self.provide(()).unsafeRunSync(on: queue)
    }
    
    /// Performs the side effects that are suspended in this EnvIO in a synchronous manner.
    ///
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: An Either wrapping errors in the left side and values on the right side. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunSyncEither<E: Error>(on queue: DispatchQueue = .main) -> Either<E, A> where F == IOPartial<E> {
        self.provide(()).unsafeRunSyncEither(on: queue)
    }
    
    /// Performs the side effects that are suspended in this EnvIO in an asynchronous manner.
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    ///   - callback: A callback function to receive the results of the evaluation. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunAsync<E: Error>(on queue: DispatchQueue = .main, _ callback: @escaping Callback<E, A>) where F == IOPartial<E> {
        self.provide(()).unsafeRunAsync(on: queue, callback)
    }
}

public extension Kleisli where A == Void {
    /// Sleep for the specified amount of time.
    ///
    /// - Parameter interval: Time to sleep.
    /// - Returns: A computation that sleeps for the specified amount of time.
    static func sleep<E: Error>(_ interval: DispatchTimeInterval) -> EnvIO<D, E, Void> where F == IOPartial<E> {
        EnvIO { _ in IO.sleep(interval) }
    }
    
    /// Sleep for the specified amount of time.
    ///
    /// - Parameter interval: Time to sleep.
    /// - Returns: A computation that sleeps for the specified amount of time.
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
