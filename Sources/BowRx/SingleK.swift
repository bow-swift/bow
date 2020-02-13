import Foundation
import RxSwift
import Bow
import BowEffects

/// Witness for the `SingleK<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForSingleK {}

/// Higher Kinded Type alias to improve readability over `Kind<ForSingleK, A>`.
public typealias SingleKOf<A> = Kind<ForSingleK, A>

public extension PrimitiveSequence where Trait == SingleTrait {
    /// Creates a higher-kinded version of this object.
    ///
    /// - Returns: A `SingleK` wrapping this object.
    func k() -> SingleK<Element> {
        return SingleK<Element>(self)
    }
}

extension PrimitiveSequence {
    func blockingGet() -> Element? {
        var result: Element?
        let group = DispatchGroup()
        group.enter()
        
        let _ = self.asObservable().subscribe(onNext: { element in
            if result == nil {
                result = element
            }
            group.leave()
        }, onError: { _ in
            group.leave()
        })
        group.wait()
        return result
    }
}

/// SingleK is a Higher Kinded Type wrapper over RxSwift's `SingleK` data type.
public final class SingleK<A>: SingleKOf<A> {
    /// Wrapped `Single` value.
    public let value: Single<A>
    
    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to SingleK.
    public static func fix(_ value: SingleKOf<A>) -> SingleK<A> {
        value as! SingleK<A>
    }
    
    /// Creates a `SingleK` from the result of evaluating a function, suspending its execution.
    ///
    /// - Parameter fa: Function providing the value to be provided in the underlying `Single`.
    /// - Returns: A `SingleK` that provides the value obtained from the closure.
    public static func from(_ fa: @escaping () throws -> A) -> SingleK<A> {
        ForSingleK.defer {
            do {
                return pure(try fa())
            } catch {
                return raiseError(error)
            }
        }^
    }
    
    /// Creates a `SingleK` from the result of evaluating a function, suspending its execution.
    ///
    /// - Parameter fa: Function providing the value to be provided in the underlying `Single`.
    /// - Returns: A `SingleK` that provides the value obtained from the closure.
    public static func invoke(_ fa: @escaping () throws -> SingleKOf<A>) -> SingleK<A> {
        ForSingleK.defer {
            do {
                return try fa()
            } catch {
                return raiseError(error)
            }
        }^
    }
    
    /// Initializes a value of this type with the underlying `Single` value.
    ///
    /// - Parameter value: Wrapped `Single` value.
    public init(_ value: Single<A>) {
        self.value = value
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to SingleK.
public postfix func ^<A>(_ value: SingleKOf<A>) -> SingleK<A> {
    SingleK.fix(value)
}

// MARK: Instance of `Functor` for `SingleK`
extension ForSingleK: Functor {
    public static func map<A, B>(_ fa: Kind<ForSingleK, A>, _ f: @escaping (A) -> B) -> Kind<ForSingleK, B> {
        SingleK.fix(fa).value.map(f).k()
    }
}

// MARK: Instance of `Applicative` for `SingleK`
extension ForSingleK: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForSingleK, A> {
        Single.just(a).k()
    }
}

// MARK: Instance of `Selective` for `SingleK`
extension ForSingleK: Selective {}

// MARK: Instance of `Monad` for `SingleK`
extension ForSingleK: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForSingleK, A>, _ f: @escaping (A) -> Kind<ForSingleK, B>) -> Kind<ForSingleK, B> {
        SingleK.fix(fa).value.flatMap { x in SingleK.fix(f(x)).value }.k()
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForSingleK, Either<A, B>>) -> Kind<ForSingleK, B> {
        try! _tailRecM(a, f).run()
    }
    
    private static func _tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> SingleKOf<Either<A, B>>) -> Trampoline<SingleKOf<B>> {
        .defer {
            let either = f(a)^.value.blockingGet()!
            return either.fold({ a in _tailRecM(a, f) },
                               { b in .done(Single.just(b).k()) })
        }
    }
}

// MARK: Instance of `ApplicativeError` for `SingleK`
extension ForSingleK: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> Kind<ForSingleK, A> {
        Single<A>.error(e).k()
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForSingleK, A>, _ f: @escaping (Error) -> Kind<ForSingleK, A>) -> Kind<ForSingleK, A> {
        SingleK.fix(fa).value.catchError { e in SingleK.fix(f(e)).value }.k()
    }
}

// MARK: Instance of `MonadError` for `SingleK`
extension ForSingleK: MonadError {}

// MARK: Instance of `MonadDefer` for `SingleK`
extension ForSingleK: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> Kind<ForSingleK, A>) -> Kind<ForSingleK, A> {
        Single.deferred { SingleK<A>.fix(fa()).value }.k()
    }
}

// MARK: Instance of `Async` for `SingleK`
extension ForSingleK: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<Error, A>) -> ()) -> Kind<ForSingleK, ()>) -> Kind<ForSingleK, A> {
        Single.create { emitter in
            procf { either in
                either.fold(
                    { error in emitter(.error(error)) },
                    { value in emitter(.success(value)) })
            }^.value.subscribe(onError: { e in emitter(.error(e)) })
        }.k()
    }

    public static func continueOn<A>(_ fa: Kind<ForSingleK, A>, _ queue: DispatchQueue) -> Kind<ForSingleK, A> {
        fa^.value.observeOn(SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: queue.label)).k()
    }

    public static func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> ()) throws -> ()) -> Kind<ForSingleK, A> {
        Single<A>.create { emitter in
            do {
                try fa { (either : Either<Error, A>) in
                    either.fold({ e in emitter(.error(e)) },
                                { a in emitter(.success(a)) })
                }
            } catch {}
            return Disposables.create()
        }.k()
    }
}

// MARK: Instance of `Effect` for `SingleK`
extension ForSingleK: Effect {
    public static func runAsync<A>(_ fa: Kind<ForSingleK, A>, _ callback: @escaping (Either<Error, A>) -> Kind<ForSingleK, ()>) -> Kind<ForSingleK, ()> {
        SingleK.fix(fa).value.flatMap { a in SingleK<()>.fix(callback(Either.right(a))).value }
            .catchError{ e in SingleK<()>.fix(callback(Either.left(e))).value }.k()
    }
}

// MARK: Instance of `ConcurrentEffect` for `SingleK`
extension ForSingleK: ConcurrentEffect {
    public static func runAsyncCancellable<A>(_ fa: Kind<ForSingleK, A>, _ callback: @escaping (Either<Error, A>) -> Kind<ForSingleK, ()>) -> Kind<ForSingleK, BowEffects.Disposable> {
        Single<BowEffects.Disposable>.create { _ in
            SingleK.fix(SingleK.fix(fa).runAsync(callback)).value.subscribe()
        }.k()
    }
}

// MARK: Instance of `Concurrent` for `SingleK`
extension ForSingleK: Concurrent {
    public static func race<A, B>(_ fa: Kind<ForSingleK, A>, _ fb: Kind<ForSingleK, B>) -> Kind<ForSingleK, Either<A, B>> {
        let left = fa.map(Either<A, B>.left)^.value.asObservable()
        let right = fb.map(Either<A, B>.right)^.value.asObservable()
        return left.amb(right).asSingle().k()
    }
    
    public static func parMap<A, B, Z>(_ fa: Kind<ForSingleK, A>, _ fb: Kind<ForSingleK, B>, _ f: @escaping (A, B) -> Z) -> Kind<ForSingleK, Z> {
        Single.zip(fa^.value, fb^.value, resultSelector: f).k()
    }
    
    public static func parMap<A, B, C, Z>(_ fa: Kind<ForSingleK, A>, _ fb: Kind<ForSingleK, B>, _ fc: Kind<ForSingleK, C>, _ f: @escaping (A, B, C) -> Z) -> Kind<ForSingleK, Z> {
        Single.zip(fa^.value, fb^.value, fc^.value, resultSelector: f).k()
    }
}

// MARK: Instance of `Bracket` for `SingleK`
extension ForSingleK: Bracket {
    public static func bracketCase<A, B>(
        acquire fa: Kind<ForSingleK, A>,
        release: @escaping (A, ExitCase<Error>) -> Kind<ForSingleK, ()>,
        use: @escaping (A) throws -> Kind<ForSingleK, B>) -> Kind<ForSingleK, B> {
        Single.create { emitter in
            fa.handleErrorWith { t in SingleK.from { emitter(.error(t)) }.value.flatMap { _ in Single.error(t) }.k() }
                .flatMap { a in
                    SingleK.invoke { try use(a) }^
                        .value
                        .do(afterSuccess: { _ in
                                _ = SingleK.defer { release(a, .completed) }^.value
                                    .subscribe(onError: { e in emitter(.error(e)) })
                            },
                            onError: { e in
                                _ = SingleK.defer { release(a, .error(e)) }^.value
                                    .subscribe(onSuccess: { emitter(.error(e)) },
                                               onError: { t in emitter(.error(t)) })
                            },
                            onDispose: {
                                _ = SingleK.defer { release(a, .canceled) }^.value.subscribe()
                            }).k()
                }^.value.subscribe(onSuccess: { b in emitter(.success(b)) })
        }.k()
    }
}
