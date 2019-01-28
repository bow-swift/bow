import Foundation
import RxSwift
import Bow
import BowEffects

public class ForObservableK {}
public typealias ObservableKOf<A> = Kind<ForObservableK, A>

public extension Observable {
    public func k() -> ObservableK<Element> {
        return ObservableK<Element>(self)
    }
    
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

public class ObservableK<A> : ObservableKOf<A> {
    public let value : Observable<A>
    
    public static func fix(_ value : ObservableKOf<A>) -> ObservableK<A> {
        return value as! ObservableK<A>
    }
    
    public static func pure(_ a : A) -> ObservableK<A> {
        return Observable.just(a).k()
    }
    
    public static func raiseError(_ e : Error) -> ObservableK<A> {
        return Observable.error(e).k()
    }
    
    public static func from(_ f : @escaping () -> A) -> ObservableK<A> {
        return suspend { pure(f()) }
    }
    
    public static func suspend(_ fa : @escaping () -> ObservableKOf<A>) -> ObservableK<A> {
        return Observable.deferred { fa().fix().value }.k()
    }
    
    public static func runAsync(_ fa : @escaping Proc<A>) -> ObservableK<A> {
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
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> ObservableKOf<Either<A, B>>) -> ObservableK<B> {
        let either = f(a).fix().value.blockingGet()!
        return either.fold({ a in tailRecM(a, f)},
                           { b in Observable.just(b).k() })
    }
    
    public init(_ value : Observable<A>) {
        self.value = value
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> ObservableK<B> {
        return value.map(f).k()
    }
    
    public func ap<AA, B>(_ fa : ObservableKOf<AA>) -> ObservableK<B> where A == (AA) -> B {
        return fa.fix().flatMap { a in self.map { ff in ff(a) } }
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> ObservableKOf<B>) -> ObservableK<B> {
        return value.flatMap { a in f(a).fix().value }.k()
    }
    
    public func concatMap<B>(_ f : @escaping (A) -> ObservableKOf<B>) -> ObservableK<B> {
        return value.concatMap { a in f(a).fix().value }.k()
    }
    
    public func foldLeft<B>(_ b : B, _ f : @escaping (B, A) -> B) -> B {
        return value.reduce(b, accumulator: f).blockingGet()!
    }
    
    public func foldRight<B>(_ lb : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ fa : ObservableK<A>) -> Eval<B> {
            if let get = fa.value.blockingGet() {
                return f(get, Eval.deferEvaluation { loop(fa.value.skip(1).k()) } )
            } else {
                return lb
            }
        }
        return Eval.deferEvaluation { loop(self) }
    }
    
    public func traverse<G, B, ApplG>(_ applicative : ApplG, _ f : @escaping (A) -> Kind<G, B>) -> Kind<G, ObservableK<B>> where ApplG : Applicative, ApplG.F == G {
        return foldRight(Eval.always { applicative.pure(Observable<B>.empty().k()) }, { a, eval in
            applicative.map2Eval(f(a), eval, { x, y in
                Observable.concat(Observable.just(x), y.value).k()
            })
        }).value()
    }
    
    public func handleErrorWith(_ f : @escaping (Error) -> ObservableK<A>) -> ObservableK<A> {
        return value.catchError { e in f(e).value }.k()
    }
    
    public func runAsync(_ callback : @escaping (Either<Error, A>) -> ObservableKOf<()>) -> ObservableK<()> {
        return value.flatMap { a in callback(Either.right(a)).fix().value }
            .catchError { e in callback(Either.left(e)).fix().value }.k()
    }
    
    public func runAsyncCancellable(_ callback : @escaping (Either<Error, A>) -> ObservableKOf<()>) -> ObservableK<BowEffects.Disposable> {
        return Observable.create { _ in
            let disposable = self.runAsync(callback).value.subscribe()
            return Disposables.create {
                disposable.dispose()
            }
        }.k()
    }
}

public extension Kind where F == ForObservableK {
    public func fix() -> ObservableK<A> {
        return ObservableK<A>.fix(self)
    }
}

public extension ObservableK {
    public static func functor() -> FunctorInstance {
        return FunctorInstance()
    }
    
    public static func applicative() -> ApplicativeInstance {
        return ApplicativeInstance()
    }
    
    public static func monad() -> MonadInstance {
        return MonadInstance()
    }
    
    public static func foldable() -> FoldableInstance {
        return FoldableInstance()
    }
    
    public static func traverse() -> TraverseInstance {
        return TraverseInstance()
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
        public typealias F = ForObservableK
        
        public func map<A, B>(_ fa: ObservableKOf<A>, _ f: @escaping (A) -> B) -> ObservableKOf<B> {
            return fa.fix().map(f)
        }
    }

    public class ApplicativeInstance : FunctorInstance, Applicative {
        public func pure<A>(_ a: A) -> ObservableKOf<A> {
            return ObservableK<A>.pure(a)
        }
        
        public func ap<A, B>(_ ff: ObservableKOf<(A) -> B>, _ fa: ObservableKOf<A>) -> ObservableKOf<B> {
            return ff.fix().ap(fa)
        }
    }

    public class MonadInstance : ApplicativeInstance, Monad {
        public func flatMap<A, B>(_ fa: ObservableKOf<A>, _ f: @escaping (A) -> ObservableKOf<B>) -> ObservableKOf<B> {
            return fa.fix().flatMap { a in f(a).fix() }
        }
        
        public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> ObservableKOf<Either<A, B>>) -> ObservableKOf<B> {
            return ObservableK<A>.tailRecM(a, f)
        }
    }

    public class FoldableInstance : Foldable {
        public typealias F = ForObservableK
        
        public func foldLeft<A, B>(_ fa: ObservableKOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
            return fa.fix().foldLeft(b, f)
        }
        
        public func foldRight<A, B>(_ fa: ObservableKOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
            return fa.fix().foldRight(b, f)
        }
    }

    public class TraverseInstance : FoldableInstance, Traverse {
        public func traverse<G, A, B, Appl>(_ fa: ObservableKOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, ObservableKOf<B>> where G == Appl.F, Appl : Applicative {
            return applicative.map(fa.fix().traverse(applicative, f), { a in a as ObservableKOf<B> })
        }
    }

    public class ApplicativeErrorInstance<Err> : ApplicativeInstance, ApplicativeError where Err : Error {
        public typealias E = Err
        
        public func raiseError<A>(_ e: Err) -> ObservableKOf<A> {
            return ObservableK<A>.raiseError(e)
        }
        
        public func handleErrorWith<A>(_ fa: ObservableKOf<A>, _ f: @escaping (Err) -> ObservableKOf<A>) -> ObservableKOf<A> {
            return fa.fix().handleErrorWith { e in f(e as! Err).fix() }
        }
    }

    public class MonadErrorInstance<Err> : MonadInstance, MonadError where Err : Error {
        public typealias E = Err
        
        public func raiseError<A>(_ e: Err) -> ObservableKOf<A> {
            return ObservableK<A>.raiseError(e)
        }
        
        public func handleErrorWith<A>(_ fa: ObservableKOf<A>, _ f: @escaping (Err) -> ObservableKOf<A>) -> ObservableKOf<A> {
            return fa.fix().handleErrorWith { e in f(e as! Err).fix() }
        }
    }

    public class MonadDeferInstance<Err> : MonadErrorInstance<Err>, MonadDefer where Err : Error {
        public func suspend<A>(_ fa: @escaping () -> ObservableKOf<A>) -> ObservableKOf<A> {
            return ObservableK<A>.suspend(fa)
        }
    }

    public class AsyncInstance<Err> : MonadDeferInstance<Err>, Async where Err : Error {
        public func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> ()) throws -> ()) -> ObservableKOf<A> {
            return ObservableK<A>.runAsync(fa)
        }
    }

    public class EffectInstance<Err> : AsyncInstance<Err>, Effect where Err : Error {
        public func runAsync<A>(_ fa: ObservableKOf<A>, _ callback: @escaping (Either<Error, A>) -> ObservableKOf<()>) -> ObservableKOf<()> {
            return fa.fix().runAsync(callback)
        }
    }

    public class ConcurrentEffectInstance<Err> : EffectInstance<Err>, ConcurrentEffect where Err : Error {
        public func runAsyncCancellable<A>(_ fa: ObservableKOf<A>, _ callback: @escaping (Either<Error, A>) -> ObservableKOf<()>) -> ObservableKOf<BowEffects.Disposable> {
            return fa.fix().runAsyncCancellable(callback)
        }
    }
}
