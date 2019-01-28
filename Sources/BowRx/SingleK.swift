import Foundation
import RxSwift
import Bow
import BowEffects

public class ForSingleK {}
public typealias SingleKOf<A> = Kind<ForSingleK, A>

public extension PrimitiveSequence where Trait == SingleTrait {
    public func k() -> SingleK<Element> {
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

public class SingleK<A> : SingleKOf<A> {
    public let value : Single<A>
    
    public static func fix(_ value : SingleKOf<A>) -> SingleK<A> {
        return value as! SingleK<A>
    }
    
    public static func pure(_ a : A) -> SingleK<A> {
        return Single.just(a).k()
    }
    
    public static func raiseError(_ error : Error) -> SingleK<A> {
        return Single<A>.error(error).k()
    }
    
    public static func from(_ fa : @escaping () -> A) -> SingleK<A> {
        return suspend { pure(fa()) }
    }
    
    public static func suspend(_ fa : @escaping () -> SingleKOf<A>) -> SingleK<A> {
        return Single.deferred { fa().fix().value }.k()
    }
    
    public static func async(_ fa : @escaping Proc<A>) -> SingleK<A> {
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
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> SingleKOf<Either<A, B>>) -> SingleK<B> {
        let either = f(a).fix().value.blockingGet()!
        return either.fold({ a in tailRecM(a, f) },
                           { b in Single.just(b).k() })
    }
    
    public init(value : Single<A>) {
        self.value = value
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> SingleK<B> {
        return value.map(f).k()
    }
    
    public func ap<AA, B>(_ fa : SingleKOf<AA>) -> SingleK<B> where A == (AA) -> B {
        return fa.fix().flatMap { a in self.map { ff in ff(a) } }
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> SingleKOf<B>) -> SingleK<B> {
        return value.flatMap { x in f(x).fix().value }.k()
    }
    
    public func handleErrorWith(_ f : @escaping (Error) -> SingleK<A>) -> SingleK<A> {
        return value.catchError { e in f(e).value }.k()
    }
    
    public func runAsync(_ callback : @escaping (Either<Error, A>) -> SingleKOf<()>) -> SingleK<()> {
        return value.flatMap { a in callback(Either.right(a)).fix().value }
            .catchError{ e in callback(Either.left(e)).fix().value }.k()
    }
    
    public func runAsyncCancellable(_ callback : @escaping (Either<Error, A>) -> SingleKOf<()>) -> SingleK<BowEffects.Disposable> {
        return Single<BowEffects.Disposable>.create { _ in
            return self.runAsync(callback).value.subscribe()
        }.k()
    }
}

public extension Kind where F == ForSingleK {
    public func fix() -> SingleK<A> {
        return SingleK<A>.fix(self)
    }
}

public extension SingleK {
    public static func functor() -> FunctorInstance {
        return FunctorInstance()
    }
    
    public static func applicative() -> ApplicativeInstance {
        return ApplicativeInstance()
    }
    
    public static func monad() -> MonadInstance {
        return MonadInstance()
    }
    
    public static func applicativeError<E>() -> ApplicativeErrorInstance<E> {
        return ApplicativeErrorInstance<E>()
    }
    
    public static func monadError<E>() -> MonadErrorInstance<E> {
        return MonadErrorInstance<E>()
    }
    
    public static func monadDefer<E>() -> MonadDeferInstance<E> {
        return MonadDeferInstance<E>()
    }
    
    public static func async<E>() -> AsyncInstance<E> {
        return AsyncInstance<E>()
    }
    
    public static func effect<E>() -> EffectInstance<E> {
        return EffectInstance<E>()
    }
    
    public static func concurrentEffect<E>() -> ConcurrentEffectInstance<E> {
        return ConcurrentEffectInstance<E>()
    }

    public class FunctorInstance : Functor {
        public typealias F = ForSingleK
        
        public func map<A, B>(_ fa: SingleKOf<A>, _ f: @escaping (A) -> B) -> SingleKOf<B> {
            return fa.fix().map(f)
        }
    }

    public class ApplicativeInstance : FunctorInstance, Applicative {
        public func pure<A>(_ a: A) -> SingleKOf<A> {
            return SingleK<A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: SingleKOf<(A) -> B>, _ fa: SingleKOf<A>) -> SingleKOf<B> {
            return ff.fix().ap(fa)
        }
    }

    public class MonadInstance : ApplicativeInstance, Monad {
        public func flatMap<A, B>(_ fa: Kind<ForSingleK, A>, _ f: @escaping (A) -> Kind<ForSingleK, B>) -> Kind<ForSingleK, B> {
            return fa.fix().flatMap(f)
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForSingleK, Either<A, B>>) -> Kind<ForSingleK, B> {
            return SingleK<A>.tailRecM(a, f)
        }
    }

    public class ApplicativeErrorInstance<Err> : ApplicativeInstance, ApplicativeError where Err : Error {
        public typealias E = Err
        
        public func raiseError<A>(_ e: Err) -> SingleKOf<A> {
            return SingleK<A>.raiseError(e)
        }
        
        public func handleErrorWith<A>(_ fa: SingleKOf<A>, _ f: @escaping (Err) -> SingleKOf<A>) -> SingleKOf<A> {
            return fa.fix().handleErrorWith{ e in f(e as! Err).fix() }
        }
    }

    public class MonadErrorInstance<Err> : MonadInstance, MonadError where Err : Error {
        public typealias E = Err
        
        public func raiseError<A>(_ e: Err) -> SingleKOf<A> {
            return SingleK<A>.raiseError(e)
        }
        
        public func handleErrorWith<A>(_ fa: SingleKOf<A>, _ f: @escaping (Err) -> SingleKOf<A>) -> SingleKOf<A> {
            return fa.fix().handleErrorWith { e in f(e as! Err).fix() }
        }
    }

    public class MonadDeferInstance<Err> : MonadErrorInstance<Err>, MonadDefer where Err : Error {
        public func suspend<A>(_ fa: @escaping () -> SingleKOf<A>) -> SingleKOf<A> {
            return SingleK<A>.suspend(fa)
        }
    }

    public class AsyncInstance<Err> : MonadDeferInstance<Err>, Async where Err : Error {
        public func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> ()) throws -> ()) -> Kind<ForSingleK, A> {
            return SingleK<A>.async(fa)
        }
    }

    public class EffectInstance<Err> : AsyncInstance<Err>, Effect where Err : Error {
        public func runAsync<A>(_ fa: Kind<ForSingleK, A>, _ callback: @escaping (Either<Error, A>) -> Kind<ForSingleK, ()>) -> Kind<ForSingleK, ()> {
            return fa.fix().runAsync(callback)
        }
    }

    public class ConcurrentEffectInstance<Err> : EffectInstance<Err>, ConcurrentEffect where Err : Error {
        public func runAsyncCancellable<A>(_ fa: Kind<ForSingleK, A>, _ callback: @escaping (Either<Error, A>) -> Kind<ForSingleK, ()>) -> Kind<ForSingleK, BowEffects.Disposable> {
            return fa.fix().runAsyncCancellable(callback)
        }
    }
}
