import Foundation
import RxSwift
import Bow
import BowEffects

/// Witness for the `ObservableK<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForObservableK {}

/// Partial application of the ObservableK type constructor, omitting the last type parameter.
public typealias ObservableKPartial = ForObservableK

/// Higher Kinded Type alias to improve readability over `Kind<ForObservableK, A>`.
public typealias ObservableKOf<A> = Kind<ForObservableK, A>

public extension Observable {
    /// Creates a higher-kinded version of this object.
    ///
    /// - Returns: An `ObservableK` wrapping this object.
    func k() -> ObservableK<Element> {
        ObservableK<Element>(self)
    }
}

extension Observable {
    func blockingGet() -> Element? {
        var result: Element?
        let flag = Atomic(false)
        let _ = self.asObservable().subscribe(onNext: { element in
            if result == nil {
                result = element
            }
            flag.value = true
        }, onError: { _ in
            flag.value = true
        }, onCompleted: {
            flag.value = true
        }, onDisposed: {
            flag.value = true
        })
        while(!flag.value) {}
        return result
    }
}

/// ObservableK is a Higher Kinded Type wrapper over RxSwift's `Observable` data type.
public final class ObservableK<A>: ObservableKOf<A> {
    /// Wrapped `Observable` value.
    public let value: Observable<A>
    
    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to ObservableK.
    public static func fix(_ value: ObservableKOf<A>) -> ObservableK<A> {
        value as! ObservableK<A>
    }
    
    /// Provides an empty `ObservableK`.
    ///
    /// - Returns: An `ObservableK` that does not provide any value.
    public static func empty() -> ObservableK<A> {
        Observable.empty().k()
    }

    /// Creates an `ObservableK` from the result of evaluating a function, suspending its execution.
    ///
    /// - Parameter f: Function providing the value to be provided in the underlying `Observable`.
    /// - Returns: An `ObservableK` that provides the value obtained from the closure.
    public static func from(_ f: @escaping () throws -> A) -> ObservableK<A> {
        ForObservableK.defer {
            do {
                return pure(try f())
            } catch {
                return raiseError(error)
            }
        }^
    }

    /// Creates an `ObservableK` from the result of evaluating a function, suspending its execution.
    ///
    /// - Parameter f: Function providing the value to be provided in the underlying `Observable`.
    /// - Returns: An `ObservableK` that provides the value obtained from the closure.
    public static func invoke(_ f: @escaping () throws -> ObservableKOf<A>) -> ObservableK<A> {
        ForObservableK.defer {
            do {
                return try f()
            } catch {
                return raiseError(error)
            }
        }^
    }
    
    /// Initializes a value of this type with the underlying `Observable` value.
    ///
    /// - Parameter value: Wrapped `Observable` value.
    public init(_ value: Observable<A>) {
        self.value = value
    }
    
    /// Wrapper over `Observable.concatMap(_:)`.
    ///
    /// - Parameter f: Function to be mapped.
    /// - Returns: An ObservableK resulting from the application of the function.
    public func concatMap<B>(_ f: @escaping (A) -> ObservableKOf<B>) -> ObservableK<B> {
        value.concatMap { a in f(a)^.value }.k()
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to ObservableK.
public postfix func ^<A>(_ value: ObservableKOf<A>) -> ObservableK<A> {
    ObservableK.fix(value)
}

// MARK: Instance of `Functor` for `ObservableK`
extension ObservableKPartial: Functor {
    public static func map<A, B>(
        _ fa: ObservableKOf<A>,
        _ f: @escaping (A) -> B) -> ObservableKOf<B> {
        fa^.value.map(f).k()
    }
}

// MARK: Instance of `Applicative` for `ObservableK`
extension ObservableKPartial: Applicative {
    public static func pure<A>(_ a: A) -> ObservableKOf<A> {
        Observable.just(a).k()
    }
}

// MARK: Instance of `Selective` for `ObservableK`
extension ObservableKPartial: Selective {}

// MARK: Instance of `Monad` for `ObservableK`
extension ObservableKPartial: Monad {
    public static func flatMap<A, B>(
        _ fa: ObservableKOf<A>,
        _ f: @escaping (A) -> ObservableKOf<B>) -> ObservableKOf<B> {
        fa^.value.flatMap { a in f(a)^.value }.k()
    }

    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> ObservableKOf<Either<A, B>>) -> ObservableKOf<B> {
        _tailRecM(a, f).run()
    }
    
    private static func _tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> ObservableKOf<Either<A, B>>) -> Trampoline<ObservableKOf<B>> {
        .defer {
            let either = f(a)^.value.blockingGet()!
            return either.fold({ a in _tailRecM(a, f)},
                               { b in .done(Observable.just(b).k()) })
        }
    }
}

// MARK: Instance of `ApplicativeError` for `ObservableK`
extension ObservableKPartial: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> ObservableKOf<A> {
        Observable.error(e).k()
    }

    public static func handleErrorWith<A>(
        _ fa: ObservableKOf<A>,
        _ f: @escaping (Error) -> ObservableKOf<A>) -> ObservableKOf<A> {
        fa^.value.catchError { e in f(e)^.value }.k()
    }
}

// MARK: Instance of `MonadError` for `ObservableK`
extension ObservableKPartial: MonadError {}

// MARK: Instance of `Foldable` for `ObservableK`
extension ObservableKPartial: Foldable {
    public static func foldLeft<A, B>(
        _ fa: ObservableKOf<A>,
        _ b: B,
        _ f: @escaping (B, A) -> B) -> B {
        fa^.value.reduce(b, accumulator: f).blockingGet()!
    }

    public static func foldRight<A, B>(
        _ fa: ObservableKOf<A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ fa: ObservableK<A>) -> Eval<B> {
            if let get = fa.value.blockingGet() {
                return f(get, Eval.defer { loop(fa.value.skip(1).k()) } )
            } else {
                return b
            }
        }
        return Eval.defer { loop(ObservableK.fix(fa)) }
    }
}

// MARK: Instance of `Traverse` for `ObservableK`
extension ObservableKPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(
        _ fa: ObservableKOf<A>,
        _ f: @escaping (A) -> Kind<G, B>)
        -> Kind<G, ObservableKOf<B>> {
        fa.foldRight(Eval.always { G.pure(Observable<B>.empty().k() as ObservableKOf<B>) }, { a, eval in
            G.map2Eval(f(a), eval, { x, y in
                Observable.concat(Observable.just(x), y^.value).k() as ObservableKOf<B>
            })
        }).value()
    }
}

// MARK: Instance of `MonadDefer` for `ObservableK`
extension ObservableKPartial: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> ObservableKOf<A>) -> ObservableKOf<A> {
        Observable.deferred { fa()^.value }.k()
    }
}

// MARK: Instance of `Async` for `ObservableK`
extension ObservableKPartial: Async {
    public static func asyncF<A>(
        _ procf: @escaping (@escaping (Either<Error, A>) -> Void)
        -> ObservableKOf<Void>) -> ObservableKOf<A> {
        Observable.create { emitter in
            procf { either in
                either.fold(
                    { error in emitter.on(.error(error)) },
                    { value in emitter.on(.next(value)); emitter.on(.completed) })
            }^.value.subscribe(onError: { e in emitter.on(.error(e)) })
        }.k()
    }

    public static func continueOn<A>(_ fa: ObservableKOf<A>, _ queue: DispatchQueue) -> ObservableKOf<A> {
        fa^.value.observeOn(SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: queue.label)).k()
    }

    public static func runAsync<A>(_ fa: @escaping ((Either<ForObservableK.E, A>) -> Void) throws -> Void) -> ObservableKOf<A> {
        Observable.create { emitter in
            do {
                try fa { either in
                    either.fold({ e in emitter.onError(e) },
                                { a in emitter.onNext(a); emitter.onCompleted() })
                }
            } catch {}
            return Disposables.create()
        }.k()
    }
}

// MARK: Instance of `Effect` for `ObservableK`
extension ObservableKPartial: Effect {
    public static func runAsync<A>(
        _ fa: ObservableKOf<A>,
        _ callback: @escaping (Either<Error, A>) -> ObservableKOf<Void>)
        -> ObservableKOf<Void> {
        fa^.value.flatMap { a in callback(Either.right(a))^.value }
            .catchError { e in callback(Either.left(e))^.value }.k()
    }
}

// MARK: Instance of `Concurrent` for `ObservableK`
extension ObservableKPartial: Concurrent {
    public static func race<A, B>(
        _ fa: ObservableKOf<A>,
        _ fb: ObservableKOf<B>) -> ObservableKOf<Either<A, B>> {
        let left = fa.map(Either<A, B>.left)^.value
        let right = fb.map(Either<A, B>.right)^.value
        return left.amb(right).k()
    }
    
    public static func parMap<A, B, Z>(
        _ fa: ObservableKOf<A>,
        _ fb: ObservableKOf<B>,
        _ f: @escaping (A, B) -> Z) -> ObservableKOf<Z> {
        Observable.zip(fa^.value, fb^.value, resultSelector: f).k()
    }
    
    public static func parMap<A, B, C, Z>(
        _ fa: ObservableKOf<A>,
        _ fb: ObservableKOf<B>,
        _ fc: ObservableKOf<C>,
        _ f: @escaping (A, B, C) -> Z) -> ObservableKOf<Z> {
        Observable.zip(fa^.value, fb^.value, fc^.value, resultSelector: f).k()
    }
}

// MARK: Instance of `ConcurrentEffect` for `ObservableK`
extension ObservableKPartial: ConcurrentEffect {
    public static func runAsyncCancellable<A>(
        _ fa: ObservableKOf<A>,
        _ callback: @escaping (Either<ForObservableK.E, A>)
        -> ObservableKOf<Void>) -> ObservableKOf<BowEffects.Disposable> {
        Observable.create { _ in
            let disposable = ObservableK.fix(ObservableK.fix(fa).runAsync(callback)).value.subscribe()
            return Disposables.create {
                disposable.dispose()
            }
        }.k()
    }
}

// MARK: Instance of `Bracket` for `ObservableK`
extension ObservableKPartial: Bracket {
    public static func bracketCase<A, B>(
        acquire fa: ObservableKOf<A>,
        release: @escaping (A, ExitCase<Error>) -> ObservableKOf<Void>,
        use: @escaping (A) throws -> ObservableKOf<B>) -> ObservableKOf<B> {
        Observable.create { emitter in
            fa.handleErrorWith { e in ObservableK.from { emitter.on(.error(e)) }.value.flatMap { _ in Observable.error(e) }.k() }^
                .concatMap { a in
                    ObservableK.invoke { try use(a)^ }
                        .value
                        .do(onError: { t in
                                _ = ObservableK.defer { release(a, .error(t)) }^.value
                                    .subscribe(onNext: { emitter.onError(t) },
                                               onError: { e in emitter.onError(e) })
                            },
                            onCompleted: {
                                _ = ObservableK.defer { release(a, .completed) }^.value.subscribe(onNext: { emitter.onCompleted() }, onError: emitter.onError)
                            },
                            onDispose: {
                                _ = ObservableK.defer { release(a, .canceled) }^.value.subscribe()
                            }).k()
                }.value.subscribe(onNext: emitter.onNext)
            }.k()
    }
}
