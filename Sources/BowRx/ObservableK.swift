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
    
    public func ap<B>(_ fa : ObservableKOf<(A) -> B>) -> ObservableK<B> {
        return flatMap { a in fa.fix().map { ff in ff(a) } }
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
    public static func functor() -> ObservableKFunctor {
        return ObservableKFunctor()
    }
    
    public static func applicative() -> ObservableKApplicative {
        return ObservableKApplicative()
    }
    
    public static func monad() -> ObservableKMonad {
        return ObservableKMonad()
    }
    
    public static func foldable() -> ObservableKFoldable {
        return ObservableKFoldable()
    }
    
    public static func traverse() -> ObservableKTraverse {
        return ObservableKTraverse()
    }
    
    public static func applicativeError<E>() -> ObservableKApplicativeError<E> {
        return ObservableKApplicativeError<E>()
    }
    
    public static func monadError<E>() -> ObservableKMonadError<E> {
        return ObservableKMonadError<E>()
    }
    
    public static func monadDefer<E>() -> ObservableKMonadDefer<E> {
        return ObservableKMonadDefer<E>()
    }
    
    public static func async<E>() -> ObservableKAsync<E> {
        return ObservableKAsync<E>()
    }
    
    public static func effect<E>() -> ObservableKEffect<E> {
        return ObservableKEffect<E>()
    }
    
    public static func concurrentEffect<E>() -> ObservableKConcurrentEffect<E> {
        return ObservableKConcurrentEffect<E>()
    }
}

public class ObservableKFunctor : Functor {
    public typealias F = ForObservableK
    
    public func map<A, B>(_ fa: ObservableKOf<A>, _ f: @escaping (A) -> B) -> ObservableKOf<B> {
        return fa.fix().map(f)
    }
}

public class ObservableKApplicative : ObservableKFunctor, Applicative {
    public func pure<A>(_ a: A) -> ObservableKOf<A> {
        return ObservableK.pure(a)
    }
    
    public func ap<A, B>(_ fa: ObservableKOf<A>, _ ff: ObservableKOf<(A) -> B>) -> ObservableKOf<B> {
        return fa.fix().ap(ff)
    }
}

public class ObservableKMonad : ObservableKApplicative, Monad {
    public func flatMap<A, B>(_ fa: ObservableKOf<A>, _ f: @escaping (A) -> ObservableKOf<B>) -> ObservableKOf<B> {
        return fa.fix().flatMap { a in f(a).fix() }
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> ObservableKOf<Either<A, B>>) -> ObservableKOf<B> {
        return ObservableK.tailRecM(a, f)
    }
}

public class ObservableKFoldable : Foldable {
    public typealias F = ForObservableK
    
    public func foldL<A, B>(_ fa: ObservableKOf<A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldLeft(b, f)
    }
    
    public func foldR<A, B>(_ fa: ObservableKOf<A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldRight(b, f)
    }
}

public class ObservableKTraverse : ObservableKFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: ObservableKOf<A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, ObservableKOf<B>> where G == Appl.F, Appl : Applicative {
        return applicative.map(fa.fix().traverse(applicative, f), { a in a as ObservableKOf<B> })
    }
}

public class ObservableKApplicativeError<Err> : ObservableKApplicative, ApplicativeError where Err : Error {
    public typealias E = Err
    
    public func raiseError<A>(_ e: Err) -> ObservableKOf<A> {
        return ObservableK.raiseError(e)
    }
    
    public func handleErrorWith<A>(_ fa: ObservableKOf<A>, _ f: @escaping (Err) -> ObservableKOf<A>) -> ObservableKOf<A> {
        return fa.fix().handleErrorWith { e in f(e as! Err).fix() }
    }
}

public class ObservableKMonadError<Err> : ObservableKMonad, MonadError where Err : Error {
    public typealias E = Err
    
    public func raiseError<A>(_ e: Err) -> ObservableKOf<A> {
        return ObservableK.raiseError(e)
    }
    
    public func handleErrorWith<A>(_ fa: ObservableKOf<A>, _ f: @escaping (Err) -> ObservableKOf<A>) -> ObservableKOf<A> {
        return fa.fix().handleErrorWith { e in f(e as! Err).fix() }
    }
}

public class ObservableKMonadDefer<Err> : ObservableKMonadError<Err>, MonadDefer where Err : Error {
    public func suspend<A>(_ fa: @escaping () -> ObservableKOf<A>) -> ObservableKOf<A> {
        return ObservableK.suspend(fa)
    }
}

public class ObservableKAsync<Err> : ObservableKMonadDefer<Err>, Async where Err : Error {
    public func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> ()) throws -> ()) -> ObservableKOf<A> {
        return ObservableK.runAsync(fa)
    }
}

public class ObservableKEffect<Err> : ObservableKAsync<Err>, Effect where Err : Error {
    public func runAsync<A>(_ fa: ObservableKOf<A>, _ callback: @escaping (Either<Error, A>) -> ObservableKOf<()>) -> ObservableKOf<()> {
        return fa.fix().runAsync(callback)
    }
}

public class ObservableKConcurrentEffect<Err> : ObservableKEffect<Err>, ConcurrentEffect where Err : Error {
    public func runAsyncCancellable<A>(_ fa: ObservableKOf<A>, _ callback: @escaping (Either<Error, A>) -> ObservableKOf<()>) -> ObservableKOf<BowEffects.Disposable> {
        return fa.fix().runAsyncCancellable(callback)
    }
}
