import Foundation
import RxSwift
import Bow
import BowEffects

/// Witness for the `ObservableK<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForObservableK {}

/// Higher Kinded Type alias to improve readability over `Kind<ForObservableK, A>`.
public typealias ObservableKOf<A> = Kind<ForObservableK, A>

public extension Observable {
    /// Creates a higher-kinded version of this object.
    ///
    /// - Returns: An `ObservableK` wrapping this object.
    func k() -> ObservableK<Element> {
        return ObservableK<Element>(self)
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
        return value as! ObservableK<A>
    }
    
    /// Provides an empty `ObservableK`.
    ///
    /// - Returns: An `ObservableK` that does not provide any value.
    public static func empty() -> ObservableK<A> {
        return Observable.empty().k()
    }

    /// Creates an `ObservableK` from the result of evaluating a function, suspending its execution.
    ///
    /// - Parameter f: Function providing the value to be provided in the underlying `Observable`.
    /// - Returns: An `ObservableK` that provides the value obtained from the closure.
    public static func from(_ f: @escaping () throws -> A) -> ObservableK<A> {
        return ForObservableK.defer {
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
        return ForObservableK.defer {
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
        return value.concatMap { a in f(a)^.value }.k()
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to ObservableK.
public postfix func ^<A>(_ value: ObservableKOf<A>) -> ObservableK<A> {
    return ObservableK.fix(value)
}

// MARK: Instance of `Functor` for `ObservableK`
extension ForObservableK: Functor {
    public static func map<A, B>(_ fa: Kind<ForObservableK, A>, _ f: @escaping (A) -> B) -> Kind<ForObservableK, B> {
        return ObservableK.fix(fa).value.map(f).k()
    }
}

// MARK: Instance of `Applicative` for `ObservableK`
extension ForObservableK: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForObservableK, A> {
        return Observable.just(a).k()
    }
}

// MARK: Instance of `Selective` for `ObservableK`
extension ForObservableK: Selective {}

// MARK: Instance of `Monad` for `ObservableK`
extension ForObservableK: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForObservableK, A>, _ f: @escaping (A) -> Kind<ForObservableK, B>) -> Kind<ForObservableK, B> {
        return ObservableK.fix(fa).value.flatMap { a in ObservableK<B>.fix(f(a)).value }.k()
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForObservableK, Either<A, B>>) -> Kind<ForObservableK, B> {
        let either = ObservableK<Either<A, B>>.fix(f(a)).value.blockingGet()!
        return either.fold({ a in tailRecM(a, f)},
                           { b in Observable.just(b).k() })
    }
}

// MARK: Instance of `ApplicativeError` for `ObservableK`
extension ForObservableK: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> Kind<ForObservableK, A> {
        return Observable.error(e).k()
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForObservableK, A>, _ f: @escaping (Error) -> Kind<ForObservableK, A>) -> Kind<ForObservableK, A> {
        return ObservableK.fix(fa).value.catchError { e in ObservableK.fix(f(e)).value }.k()
    }
}

// MARK: Instance of `MonadError` for `ObservableK`
extension ForObservableK: MonadError {}

// MARK: Instance of `Foldable` for `ObservableK`
extension ForObservableK: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForObservableK, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return ObservableK.fix(fa).value.reduce(b, accumulator: f).blockingGet()!
    }

    public static func foldRight<A, B>(_ fa: Kind<ForObservableK, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
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
extension ForObservableK: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForObservableK, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForObservableK, B>> {
        return fa.foldRight(Eval.always { G.pure(Observable<B>.empty().k() as ObservableKOf<B>) }, { a, eval in
            G.map2Eval(f(a), eval, { x, y in
                Observable.concat(Observable.just(x), ObservableK.fix(y).value).k() as ObservableKOf<B>
            })
        }).value()
    }
}

// MARK: Instance of `MonadDefer` for `ObservableK`
extension ForObservableK: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> Kind<ForObservableK, A>) -> Kind<ForObservableK, A> {
        return Observable.deferred { ObservableK<A>.fix(fa()).value }.k()
    }
}

// MARK: Instance of `Async` for `ObservableK`
extension ForObservableK: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<Error, A>) -> ()) -> Kind<ForObservableK, ()>) -> Kind<ForObservableK, A> {
        return Observable.create { emitter in
            procf { either in
                either.fold(
                    { error in emitter.on(.error(error)) },
                    { value in emitter.on(.next(value)); emitter.on(.completed) })
            }^.value.subscribe(onError: { e in emitter.on(.error(e)) })
        }.k()
    }

    public static func continueOn<A>(_ fa: Kind<ForObservableK, A>, _ queue: DispatchQueue) -> Kind<ForObservableK, A> {
        return fa^.value.observeOn(SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: queue.label)).k()
    }

    public static func runAsync<A>(_ fa: @escaping ((Either<ForObservableK.E, A>) -> ()) throws -> ()) -> Kind<ForObservableK, A> {
        return Observable.create { emitter in
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
extension ForObservableK: Effect {
    public static func runAsync<A>(_ fa: Kind<ForObservableK, A>, _ callback: @escaping (Either<Error, A>) -> Kind<ForObservableK, ()>) -> Kind<ForObservableK, ()> {
        return ObservableK.fix(fa).value.flatMap { a in ObservableK<()>.fix(callback(Either.right(a))).value }
            .catchError { e in ObservableK<()>.fix(callback(Either.left(e))).value }.k()
    }
}

// MARK: Instance of `Concurrent` for `ObservableK`
extension ForObservableK: Concurrent {
    public static func race<A, B>(_ fa: Kind<ForObservableK, A>, _ fb: Kind<ForObservableK, B>) -> Kind<ForObservableK, Either<A, B>> {
        let left = fa.map(Either<A, B>.left)^.value
        let right = fb.map(Either<A, B>.right)^.value
        return left.amb(right).k()
    }
    
    public static func parMap<A, B, Z>(_ fa: Kind<ForObservableK, A>, _ fb: Kind<ForObservableK, B>, _ f: @escaping (A, B) -> Z) -> Kind<ForObservableK, Z> {
        return Observable.zip(fa^.value, fb^.value, resultSelector: f).k()
    }
    
    public static func parMap<A, B, C, Z>(_ fa: Kind<ForObservableK, A>, _ fb: Kind<ForObservableK, B>, _ fc: Kind<ForObservableK, C>, _ f: @escaping (A, B, C) -> Z) -> Kind<ForObservableK, Z> {
        return Observable.zip(fa^.value, fb^.value, fc^.value, resultSelector: f).k()
    }
}

// MARK: Instance of `ConcurrentEffect` for `ObservableK`
extension ForObservableK: ConcurrentEffect {
    public static func runAsyncCancellable<A>(_ fa: Kind<ForObservableK, A>, _ callback: @escaping (Either<ForObservableK.E, A>) -> Kind<ForObservableK, ()>) -> Kind<ForObservableK, BowEffects.Disposable> {
        return Observable.create { _ in
            let disposable = ObservableK.fix(ObservableK.fix(fa).runAsync(callback)).value.subscribe()
            return Disposables.create {
                disposable.dispose()
            }
        }.k()
    }
}

// MARK: Instance of `Bracket` for `ObservableK`
extension ForObservableK: Bracket {
    public static func bracketCase<A, B>(
        acquire fa: Kind<ForObservableK, A>,
        release: @escaping (A, ExitCase<Error>) -> Kind<ForObservableK, ()>,
        use: @escaping (A) throws -> Kind<ForObservableK, B>) -> Kind<ForObservableK, B> {
        return Observable.create { emitter in
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
