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
    /// Creates an EnvIO from a side-effectful function that has a dependency.
    ///
    /// - Parameter f: Side-effectful function. Errors thrown from this function must be of type `E`; otherwise, a fatal error will happen.
    /// - Returns: An EnvIO value suspending the execution of the side effect.
    static func invoke<E: Error>(_ f: @escaping (D) throws -> A) -> EnvIO<D, E, A>
        where F == IOPartial<E> {
        EnvIO { env in IO.invoke { try f(env) } }
    }
    
    /// Creates an EnvIO from a side-effectful function returning an Either that has a dependency.
    ///
    /// - Parameter f: Side-effectful function.
    /// - Returns: An EnvIO value suspending the execution of the side effect.
    static func invokeEither<E: Error>(_ f: @escaping (D) -> Either<E, A>) -> EnvIO<D, E, A>
        where F == IOPartial<E> {
        EnvIO { env in IO.invokeEither { f(env) } }
    }
    
    /// Creates an EnvIO from a side-effectful function returning a Result that has a dependency.
    ///
    /// - Parameter f: Side-effectful function.
    /// - Returns: An EnvIO value suspending the execution of the side effect.
    static func invokeResult<E: Error>(_ f: @escaping (D) -> Result<A, E>) -> EnvIO<D, E, A>
        where F == IOPartial<E> {
        EnvIO { env in IO.invokeResult { f(env) } }
    }
    
    /// Creates an EnvIO from a side-effectful function returning a Validated that has a dependency.
    ///
    /// - Parameter f: Side-effectful function.
    /// - Returns: An EnvIO value suspending the execution of the side effect.
    static func invokeValidated<E: Error>(_ f: @escaping (D) -> Validated<E, A>) -> EnvIO<D, E, A>
        where F == IOPartial<E> {
        EnvIO { env in IO.invokeValidated { f(env) } }
    }
    
    /// Transforms the error type of this EnvIO
    ///
    /// - Parameter f: Function transforming the error.
    /// - Returns: An EnvIO value with the new error type.
    func mapError<E: Error, EE: Error>(_ f: @escaping (E) -> EE) -> EnvIO<D, EE, A>
        where F == IOPartial<E> {
        EnvIO { env in self.run(env)^.mapError(f) }
    }
    
    /// Provides the required environment.
    ///
    /// - Parameter d: Environment.
    /// - Returns: An IO resulting from running this computation with the provided environment.
    func provide<E: Error>(_ d: D) -> IO<E, A>
        where F == IOPartial<E> {
        self.run(d)^
    }
    
    /// Retries this computation if it fails based on the provided retrial policy.
    ///
    /// This computation will be at least executed once, and if it fails, it will be retried according to the policy.
    ///
    /// - Parameter policy: Retrial policy.
    /// - Returns: A computation that is retried based on the provided policy when it fails.
    func retry<S, O, E: Error>(_ policy: Schedule<D, E, S, O>) -> EnvIO<D, E, A>
        where F == IOPartial<E> {
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
    func retry<S, O, B, E: Error>(
        _ policy: Schedule<D, E, S, O>,
        orElse: @escaping (E, O) -> EnvIO<D, E, B>) -> EnvIO<D, E, Either<B, A>>
        where F == IOPartial<E> {
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
    func `repeat`<S, O, E: Error>(
        _ policy: Schedule<D, A, S, O>,
        onUpdateError: @escaping () -> E = { fatalError("Impossible to update error on repeat.") }) -> EnvIO<D, E, O>
        where F == IOPartial<E> {
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
    func `repeat`<S, O, B, E: Error>(
        _ policy: Schedule<D, A, S, O>,
        onUpdateError: @escaping () -> E = { fatalError("Impossible to update error on repeat.") },
        orElse: @escaping (E, O?) -> EnvIO<D, E, B>) -> EnvIO<D, E, Either<B, O>>
        where F == IOPartial<E> {
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
    
    /// Transforms the type arguments of this EnvIO.
    ///
    /// - Parameters:
    ///   - fe: Function to transform the error type argument.
    ///   - fa: Function to transform the output type argument.
    /// - Returns: An EnvIO with both type arguments transformed.
    func bimap<E: Error, EE: Error, B>(
        _ fe: @escaping (E) -> EE,
        _ fa: @escaping (A) -> B) -> EnvIO<D, EE, B>
        where F == IOPartial<E> {
        mapError(fe).map(fa)^
    }
    
    /// Performs the side effects that are suspended in this IO in a synchronous manner.
    ///
    /// - Parameters:
    ///   - d: Dependencies needed in this operation.
    ///   - queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: Value produced after running the suspended side effects.
    /// - Throws: Error of type `E` that may happen during the evaluation of the side-effects. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunSync<E: Error>(
        with d: D,
        on queue: DispatchQueue = .main) throws -> A
        where F == IOPartial<E> {
        try self.provide(d).unsafeRunSync(on: queue)
    }
    
    /// Performs the side effects that are suspended in this EnvIO in a synchronous manner.
    ///
    /// - Parameters:
    ///   - d: Dependencies needed in this operation.
    ///   - queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: An Either wrapping errors in the left side and values on the right side. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunSyncEither<E: Error>(
        with d: D,
        on queue: DispatchQueue = .main) -> Either<E, A>
        where F == IOPartial<E> {
        self.provide(d).unsafeRunSyncEither(on: queue)
    }
    
    /// Performs the side effects that are suspended in this EnvIO in an asynchronous manner.
    ///
    /// - Parameters:
    ///   - d: Dependencies needed in this operation.
    ///   - queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    ///   - callback: A callback function to receive the results of the evaluation. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunAsync<E: Error>(
        with d: D,
        on queue: DispatchQueue = .main,
        _ callback: @escaping Callback<E, A> = { _ in })
        where F == IOPartial<E> {
        self.provide(d).unsafeRunAsync(on: queue, callback)
    }
}

public extension Kleisli where F == IOPartial<Error> {
    /// Creates an EnvIO from a side-effectful function returning a Try that has a dependency.
    ///
    /// - Parameter f: Side-effectful function.
    /// - Returns: An EnvIO value suspending the execution of the side effect.
    static func invokeTry(_ f: @escaping (D) -> Try<A>) -> EnvIO<D, Error, A> {
        EnvIO { env in IO.invokeTry { f(env) } }
    }
}

public extension Kleisli where D == Any {
    /// Performs the side effects that are suspended in this IO in a synchronous manner.
    ///
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: Value produced after running the suspended side effects.
    /// - Throws: Error of type `E` that may happen during the evaluation of the side-effects. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunSync<E: Error>(on queue: DispatchQueue = .main) throws -> A
        where F == IOPartial<E> {
        try self.provide(()).unsafeRunSync(on: queue)
    }
    
    /// Performs the side effects that are suspended in this EnvIO in a synchronous manner.
    ///
    /// - Parameter queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    /// - Returns: An Either wrapping errors in the left side and values on the right side. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunSyncEither<E: Error>(on queue: DispatchQueue = .main) -> Either<E, A>
        where F == IOPartial<E> {
        self.provide(()).unsafeRunSyncEither(on: queue)
    }
    
    /// Performs the side effects that are suspended in this EnvIO in an asynchronous manner.
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue used to execute the side effects. Defaults to the main queue.
    ///   - callback: A callback function to receive the results of the evaluation. Errors of other types thrown from the evaluation of this IO will cause a fatal error.
    func unsafeRunAsync<E: Error>(
        on queue: DispatchQueue = .main,
        _ callback: @escaping Callback<E, A> = { _ in })
        where F == IOPartial<E> {
        self.provide(()).unsafeRunAsync(on: queue, callback)
    }
}

public extension Kleisli where A == Void {
    /// Sleep for the specified amount of time.
    ///
    /// - Parameter interval: Time to sleep.
    /// - Returns: A computation that sleeps for the specified amount of time.
    static func sleep<E: Error>(_ interval: DispatchTimeInterval) -> EnvIO<D, E, Void>
        where F == IOPartial<E> {
        EnvIO { _ in IO.sleep(interval) }
    }
    
    /// Sleep for the specified amount of time.
    ///
    /// - Parameter interval: Time to sleep.
    /// - Returns: A computation that sleeps for the specified amount of time.
    static func sleep<E: Error>(_ interval: TimeInterval) -> EnvIO<D, E, Void>
        where F == IOPartial<E> {
        EnvIO { _ in IO.sleep(interval) }
    }
}

// MARK: Instance of MonadDefer for Kleisli

extension KleisliPartial: MonadDefer where F: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> KleisliOf<F, D, A>) -> KleisliOf<F, D, A> {
        Kleisli { d in F.defer { fa()^.run(d) } }
    }
}

// MARK: Instance of Async for Kleisli

extension KleisliPartial: Async where F: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<F.E, A>) -> ()) -> KleisliOf<F, D, ()>) -> KleisliOf<F, D, A> {
        Kleisli { d in
            F.asyncF { callback in
                procf(callback)^.run(d)
            }
        }
    }
    
    public static func continueOn<A>(
        _ fa: KleisliOf<F, D, A>,
        _ queue: DispatchQueue) -> KleisliOf<F, D, A> {
        Kleisli { d in
            fa^.run(d).continueOn(queue)
        }
    }
}

// MARK: Instance of Concurrent for Kleisli

extension KleisliPartial: Concurrent where F: Concurrent {
    public static func race<A, B>(
        _ fa: KleisliOf<F, D, A>,
        _ fb: KleisliOf<F, D, B>) -> KleisliOf<F, D, Either<A, B>> {
        Kleisli { d in
            F.race(fa^.run(d), fb^.run(d))
        }
    }
    
    public static func parMap<A, B, Z>(
        _ fa: KleisliOf<F, D, A>,
        _ fb: KleisliOf<F, D, B>,
        _ f: @escaping (A, B) -> Z) -> KleisliOf<F, D, Z> {
        Kleisli { d in
            F.parMap(fa^.run(d), fb^.run(d), f)
        }
    }
    
    public static func parMap<A, B, C, Z>(
        _ fa: KleisliOf<F, D, A>,
        _ fb: KleisliOf<F, D, B>,
        _ fc: KleisliOf<F, D, C>,
        _ f: @escaping (A, B, C) -> Z) -> KleisliOf<F, D, Z> {
        Kleisli { d in
            F.parMap(fa^.run(d), fb^.run(d), fc^.run(d), f)
        }
    }
}
