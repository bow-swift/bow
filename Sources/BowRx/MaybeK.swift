import Foundation
import RxSwift
import Bow
import BowEffects

/// Witness for the `MaybeK<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForMaybeK {}

/// Partial application of the MaybeK type constructor, omitting the last type parameter.
public typealias MaybeKPartial = ForMaybeK

/// Higher Kinded Type alias to improve readability over `Kind<ForMaybeK, A>`.
public typealias MaybeKOf<A> = Kind<ForMaybeK, A>

public extension PrimitiveSequence where Trait == MaybeTrait {
    /// Creates a higher-kinded version of this object.
    ///
    /// - Returns: A `MaybeK` wrapping this object.
    func k() -> MaybeK<Element> {
        MaybeK(self)
    }
}

/// MaybeK is a Higher Kinded Type wrapper over RxSwift's `Maybe` data type.
public final class MaybeK<A>: MaybeKOf<A> {
    /// Wrapped `Maybe` value.
    public let value: Maybe<A>

    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to MaybeK.
    public static func fix(_ value: MaybeKOf<A>) -> MaybeK<A> {
        value as! MaybeK<A>
    }

    /// Provides an empty `MaybeK`.
    ///
    /// - Returns: A `MaybeK` that does not provide any value.
    public static func empty() -> MaybeK<A> {
        Maybe.empty().k()
    }
    
    /// Creates a `MaybeK` from the result of evaluating a function, suspending its execution.
    ///
    /// - Parameter f: Function providing the value to be provided in the underlying `Maybe`.
    /// - Returns: A `MaybeK` that provides the value obtained from the closure.
    public static func from(_ f: @escaping () throws -> A) -> MaybeK<A> {
        ForMaybeK.defer {
            do {
                return pure(try f())
            } catch {
                return raiseError(error)
            }
        }^
    }
    
    /// Creates a `MaybeK` from the result of evaluating a function, suspending its execution.
    ///
    /// - Parameter f: Function providing the value to be provided by the underlying `Maybe`.
    /// - Returns: A `MaybeK` that provides the value obtained from the closure.
    public static func invoke(_ f: @escaping () throws -> MaybeKOf<A>) -> MaybeK<A> {
        ForMaybeK.defer {
            do {
                return try f()
            } catch {
                return raiseError(error)
            }
        }^
    }

    /// Initializes a value of this type with the underlying `Maybe` value.
    ///
    /// - Parameter value: Wrapped `Maybe` value.
    public init(_ value: Maybe<A>) {
        self.value = value
    }

    /// Performs an action based on the result of the execution of the underlying `Maybe`.
    ///
    /// - Parameters:
    ///   - ifEmpty: Action to be performed if the underlying `Maybe` is empty.
    ///   - ifSome: Action to be perfomed if the underlying `Maybe` has a value.
    /// - Returns: Result of performing either operation.
    public func fold<B>(_ ifEmpty: @escaping () -> B, _ ifSome: @escaping (A) -> B) -> B {
        if let result = value.blockingGet() {
            return ifSome(result)
        } else {
            return ifEmpty()
        }
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to MaybeK.
public postfix func ^<A>(_ value: MaybeKOf<A>) -> MaybeK<A> {
    MaybeK.fix(value)
}

// MARK: Instance of `Functor` for `MaybeK`
extension MaybeKPartial: Functor {
    public static func map<A, B>(
        _ fa: MaybeKOf<A>,
        _ f: @escaping (A) -> B) -> MaybeKOf<B> {
        fa^.value.map(f).k()
    }
}

// MARK: Instance of `Applicative` for `MaybeK`
extension MaybeKPartial: Applicative {
    public static func pure<A>(_ a: A) -> MaybeKOf<A> {
        Maybe.just(a).k()
    }
}

// MARK: Instance of `Selective` for `MaybeK`
extension MaybeKPartial: Selective {}

// MARK: Instance of `Monad` for `MaybeK`
extension MaybeKPartial: Monad {
    public static func flatMap<A, B>(
        _ fa: MaybeKOf<A>,
        _ f: @escaping (A) -> MaybeKOf<B>) -> MaybeKOf<B> {
        fa^.value.flatMap { a in f(a)^.value }.k()
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> MaybeKOf<Either<A, B>>) -> MaybeKOf<B> {
        _tailRecM(a, f).run()
    }
    
    private static func _tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> MaybeKOf<Either<A, B>>) -> Trampoline<MaybeKOf<B>> {
        .defer {
            let either = f(a)^.value.blockingGet()!
            return either.fold({ a in _tailRecM(a, f) },
                        { b in .done(Maybe.just(b).k()) })
        }
    }
}

// MARK: Instance of `Foldable` for `MaybeK`
extension MaybeKPartial: Foldable {
    public static func foldLeft<A, B>(
        _ fa: MaybeKOf<A>,
        _ b: B,
        _ f: @escaping (B, A) -> B) -> B {
        fa^.fold(constant(b), { a in f(b, a) })
    }

    public static func foldRight<A, B>(
        _ fa: MaybeKOf<A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        Eval.defer { fa^.fold(constant(b), { a in f(a, b) }) }
    }
}

// MARK: Instance of `ApplicativeError` for `MaybeK`
extension MaybeKPartial: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> MaybeKOf<A> {
        Maybe.error(e).k()
    }

    public static func handleErrorWith<A>(
        _ fa: MaybeKOf<A>,
        _ f: @escaping (Error) -> MaybeKOf<A>) -> MaybeKOf<A> {
        fa^.value.catchError { e in f(e)^.value }.k()
    }
}

// MARK: Instance of `MonadError` for `MaybeK`
extension MaybeKPartial: MonadError {}

// MARK: Instance of `MonadDefer` for `MaybeK`
extension MaybeKPartial: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> MaybeKOf<A>) -> MaybeKOf<A> {
        Maybe.deferred { fa()^.value }.k()
    }
}

// MARK: Instance of `Async` for `MaybeK`
extension MaybeKPartial: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<Error, A>) -> Void) -> MaybeKOf<Void>) -> MaybeKOf<A> {
        Maybe<A>.create { emitter in
            procf { either in
                either.fold(
                    { error in emitter(.error(error)) },
                    { value in emitter(.success(value)) })
            }^.value.subscribe(onError: { e in emitter(.error(e)) })
        }.k()
    }
    
    public static func continueOn<A>(
        _ fa: MaybeKOf<A>,
        _ queue: DispatchQueue) -> MaybeKOf<A> {
        fa^.value.observeOn(SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: queue.label)).k()
    }
    
    public static func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> Void) throws -> ()) -> MaybeKOf<A> {
        Maybe.create { emitter in
            do {
                try fa { either in
                    either.fold({ e in emitter(.error(e)) },
                                { a in emitter(.success(a)) })
                }
            } catch {}
            return Disposables.create()
        }.k()
    }
}

// MARK: Instance of `Effect` for `MaybeK`
extension MaybeKPartial: Effect {
    public static func runAsync<A>(
        _ fa: MaybeKOf<A>,
        _ callback: @escaping (Either<ForMaybeK.E, A>) -> MaybeKOf<Void>) -> MaybeKOf<Void> {
        fa^.value.flatMap { a in MaybeK<()>.fix(callback(Either.right(a))).value }
            .catchError { e in MaybeK<()>.fix(callback(Either.left(e))).value }.k()
    }
}

// MARK: Instance of `Concurrent` for `MaybeK`
extension MaybeKPartial: Concurrent {
    public static func race<A, B>(
        _ fa: MaybeKOf<A>,
        _ fb: MaybeKOf<B>) -> MaybeKOf<Either<A, B>> {
        let left = fa.map(Either<A, B>.left)^.value.asObservable()
        let right = fb.map(Either<A, B>.right)^.value.asObservable()
        return left.amb(right).asMaybe().k()
    }
    
    public static func parMap<A, B, Z>(
        _ fa: MaybeKOf<A>,
        _ fb: MaybeKOf<B>,
        _ f: @escaping (A, B) -> Z) -> MaybeKOf<Z> {
        Maybe.zip(fa^.value, fb^.value, resultSelector: f).k()
    }
    
    public static func parMap<A, B, C, Z>(
        _ fa: MaybeKOf<A>,
        _ fb: MaybeKOf<B>,
        _ fc: MaybeKOf<C>,
        _ f: @escaping (A, B, C) -> Z) -> MaybeKOf<Z> {
        Maybe.zip(fa^.value, fb^.value, fc^.value, resultSelector: f).k()
    }
}

// MARK: Instance of `Bracket` for `MaybeK`
extension MaybeKPartial: Bracket {
    public static func bracketCase<A, B>(
        acquire fa: MaybeKOf<A>,
        release: @escaping (A, ExitCase<Error>) -> MaybeKOf<Void>,
        use: @escaping (A) throws -> MaybeKOf<B>) -> MaybeKOf<B> {
        Maybe.create { emitter in
            fa.handleErrorWith { t in MaybeK.from { emitter(.error(t)) }.value.flatMap { Maybe.error(t) }.k() }
                .flatMap { a in
                    MaybeK.invoke { try use(a)^ }^
                    .value
                    .do(onError: { t in
                            let _ = MaybeK.defer { release(a, .error(t)) }^.value
                                .subscribe(onSuccess: { _ in emitter(.error(t)) },
                                           onError: { e in emitter(.error(e)) })
                        },
                        afterCompleted: {
                            let _ = MaybeK.defer { release(a, .completed) }^.value
                                .subscribe(onSuccess: { emitter(.completed) },
                                           onError: { e in emitter(.error(e)) })
                        },
                        onDispose: {
                            let _ = MaybeK.defer { release(a, .canceled) }^.value.subscribe()
                        })
                    .k()
                }^.value.subscribe(onSuccess: { b in emitter(.success(b)) })
        }.k()
    }
}
