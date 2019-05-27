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

public class SingleK<A>: SingleKOf<A> {
    public let value: Single<A>
    
    public static func fix(_ value: SingleKOf<A>) -> SingleK<A> {
        return value as! SingleK<A>
    }
    
    public static func from(_ fa: @escaping () -> A) -> SingleK<A> {
        return SingleK.fix(suspend { pure(fa()) })
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

extension ForSingleK: Functor {
    public static func map<A, B>(_ fa: Kind<ForSingleK, A>, _ f: @escaping (A) -> B) -> Kind<ForSingleK, B> {
        return SingleK.fix(fa).value.map(f).k()
    }
}

extension ForSingleK: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForSingleK, A> {
        return Single.just(a).k()
    }
}

// MARK: Instance of `Selective` for `SingleK`
extension ForSingleK: Selective {}

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

extension ForSingleK: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> Kind<ForSingleK, A> {
        return Single<A>.error(e).k()
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForSingleK, A>, _ f: @escaping (Error) -> Kind<ForSingleK, A>) -> Kind<ForSingleK, A> {
        return SingleK.fix(fa).value.catchError { e in SingleK.fix(f(e)).value }.k()
    }
}

extension ForSingleK: MonadError {}

extension ForSingleK: MonadDefer {
    public static func suspend<A>(_ fa: @escaping () -> Kind<ForSingleK, A>) -> Kind<ForSingleK, A> {
        return Single.deferred { SingleK<A>.fix(fa()).value }.k()
    }
}

extension ForSingleK: Async {
    public static func runAsync<A>(_ fa: @escaping (@escaping (Either<Error, A>) -> ()) throws -> ()) -> Kind<ForSingleK, A> {
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

extension ForSingleK: Effect {
    public static func runAsync<A>(_ fa: Kind<ForSingleK, A>, _ callback: @escaping (Either<Error, A>) -> Kind<ForSingleK, ()>) -> Kind<ForSingleK, ()> {
        return SingleK.fix(fa).value.flatMap { a in SingleK<()>.fix(callback(Either.right(a))).value }
            .catchError{ e in SingleK<()>.fix(callback(Either.left(e))).value }.k()
    }
}

extension ForSingleK: ConcurrentEffect {
    public static func runAsyncCancellable<A>(_ fa: Kind<ForSingleK, A>, _ callback: @escaping (Either<Error, A>) -> Kind<ForSingleK, ()>) -> Kind<ForSingleK, BowEffects.Disposable> {
        return Single<BowEffects.Disposable>.create { _ in
            return SingleK.fix(SingleK.fix(fa).runAsync(callback)).value.subscribe()
            }.k()
    }
}
