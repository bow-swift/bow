import Foundation
import RxSwift
import Bow
import BowEffects

public final class ForSingleK {}
public typealias SingleKOf<A> = Kind<ForSingleK, A>

public extension PrimitiveSequence where Trait == SingleTrait {
    func k() -> SingleK<Element> {
        return SingleK<Element>(value: self)
    }
}

// There should be a better way to do this...
extension PrimitiveSequence {
    func blockingGet() -> Element? {
        var result : Element?
        var flag = false
        let _ = self.asObservable().subscribe(onNext: { element in
            if result == nil {
                result = element
            }
            flag = true
        }, onError: { _ in
            flag = true
        }, onCompleted: {
            flag = true
        }, onDisposed: {
            flag = true
        })
        while(!flag) {}
        return result
    }
}

public final class SingleK<A>: SingleKOf<A> {
    public let value: Single<A>
    
    public static func fix(_ value: SingleKOf<A>) -> SingleK<A> {
        return value as! SingleK<A>
    }
    
    public static func from(_ fa: @escaping () throws -> A) -> SingleK<A> {
        return ForSingleK.defer {
            do {
                return pure(try fa())
            } catch {
                return raiseError(error)
            }
        }^
    }
    
    public static func invoke(_ fa: @escaping () throws -> SingleKOf<A>) -> SingleK<A> {
        return ForSingleK.defer {
            do {
                return try fa()
            } catch {
                return raiseError(error)
            }
        }^
    }
    
    public init(value: Single<A>) {
        self.value = value
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to SingleK.
public postfix func ^<A>(_ value: SingleKOf<A>) -> SingleK<A> {
    return SingleK.fix(value)
}

// MARK: Instance of `Functor` for `SingleK`
extension ForSingleK: Functor {
    public static func map<A, B>(_ fa: Kind<ForSingleK, A>, _ f: @escaping (A) -> B) -> Kind<ForSingleK, B> {
        return SingleK.fix(fa).value.map(f).k()
    }
}

// MARK: Instance of `Applicative` for `SingleK`
extension ForSingleK: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForSingleK, A> {
        return Single.just(a).k()
    }
}

// MARK: Instance of `Selective` for `SingleK`
extension ForSingleK: Selective {}

// MARK: Instance of `Monad` for `SingleK`
extension ForSingleK: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForSingleK, A>, _ f: @escaping (A) -> Kind<ForSingleK, B>) -> Kind<ForSingleK, B> {
        return SingleK.fix(fa).value.flatMap { x in SingleK.fix(f(x)).value }.k()
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForSingleK, Either<A, B>>) -> Kind<ForSingleK, B> {
        let either = SingleK<Either<A, B>>.fix(f(a)).value.blockingGet()!
        return either.fold({ a in tailRecM(a, f) },
                           { b in Single.just(b).k() })
    }
}

// MARK: Instance of `ApplicativeError` for `SingleK`
extension ForSingleK: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> Kind<ForSingleK, A> {
        return Single<A>.error(e).k()
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForSingleK, A>, _ f: @escaping (Error) -> Kind<ForSingleK, A>) -> Kind<ForSingleK, A> {
        return SingleK.fix(fa).value.catchError { e in SingleK.fix(f(e)).value }.k()
    }
}

// MARK: Instance of `MonadError` for `SingleK`
extension ForSingleK: MonadError {}

// MARK: Instance of `MonadDefer` for `SingleK`
extension ForSingleK: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> Kind<ForSingleK, A>) -> Kind<ForSingleK, A> {
        return Single.deferred { SingleK<A>.fix(fa()).value }.k()
    }
}

// MARK: Instance of `Async` for `SingleK`
extension ForSingleK: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<Error, A>) -> ()) -> Kind<ForSingleK, ()>) -> Kind<ForSingleK, A> {
        return Single.create { emitter in
            procf { either in
                either.fold(
                    { error in emitter(.error(error)) },
                    { value in emitter(.success(value)) })
            }^.value.subscribe(onError: { e in emitter(.error(e)) })
        }.k()
    }

    public static func continueOn<A>(_ fa: Kind<ForSingleK, A>, _ queue: DispatchQueue) -> Kind<ForSingleK, A> {
        return fa^.value.observeOn(SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: queue.label)).k()
    }

    public static func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> ()) throws -> ()) -> Kind<ForSingleK, A> {
        return Single<A>.create { emitter in
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
        return SingleK.fix(fa).value.flatMap { a in SingleK<()>.fix(callback(Either.right(a))).value }
            .catchError{ e in SingleK<()>.fix(callback(Either.left(e))).value }.k()
    }
}

// MARK: Instance of `ConcurrentEffect` for `SingleK`
extension ForSingleK: ConcurrentEffect {
    public static func runAsyncCancellable<A>(_ fa: Kind<ForSingleK, A>, _ callback: @escaping (Either<Error, A>) -> Kind<ForSingleK, ()>) -> Kind<ForSingleK, BowEffects.Disposable> {
        return Single<BowEffects.Disposable>.create { _ in
            return SingleK.fix(SingleK.fix(fa).runAsync(callback)).value.subscribe()
            }.k()
    }
}

// MARK: Instance of `Concurrent` for `SingleK`
extension ForSingleK: Concurrent {
    public static func parMap<A, B, Z>(_ fa: Kind<ForSingleK, A>, _ fb: Kind<ForSingleK, B>, _ f: @escaping (A, B) -> Z) -> Kind<ForSingleK, Z> {
        return Single.zip(fa^.value, fb^.value, resultSelector: f).k()
    }
    
    public static func parMap<A, B, C, Z>(_ fa: Kind<ForSingleK, A>, _ fb: Kind<ForSingleK, B>, _ fc: Kind<ForSingleK, C>, _ f: @escaping (A, B, C) -> Z) -> Kind<ForSingleK, Z> {
        return Single.zip(fa^.value, fb^.value, fc^.value, resultSelector: f).k()
    }
}

// MARK: Instance of `Bracket` for `SingleK`
extension ForSingleK: Bracket {
    public static func bracketCase<A, B>(
        _ fa: Kind<ForSingleK, A>,
        _ release: @escaping (A, ExitCase<Error>) -> Kind<ForSingleK, ()>,
        _ use: @escaping (A) throws -> Kind<ForSingleK, B>) -> Kind<ForSingleK, B> {
        return Single.create { emitter in
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
