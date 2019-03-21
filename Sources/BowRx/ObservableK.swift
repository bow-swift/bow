import Foundation
import RxSwift
import Bow
import BowEffects

public final class ForObservableK {}
public typealias ObservableKOf<A> = Kind<ForObservableK, A>

public extension Observable {
    public func k() -> ObservableK<Element> {
        return ObservableK<Element>(self)
    }
    
    func blockingGet() -> Element? {
        var result: Element?
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

public class ObservableK<A>: ObservableKOf<A> {
    public let value: Observable<A>
    
    public static func fix(_ value: ObservableKOf<A>) -> ObservableK<A> {
        return value as! ObservableK<A>
    }

    public static func from(_ f: @escaping () -> A) -> ObservableK<A> {
        return ObservableK.fix(suspend { pure(f()) })
    }
    
    public init(_ value: Observable<A>) {
        self.value = value
    }
    
    public func concatMap<B>(_ f: @escaping (A) -> ObservableKOf<B>) -> ObservableK<B> {
        return value.concatMap { a in ObservableK<B>.fix(f(a)).value }.k()
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to ObservableK.
public postfix func ^<A>(_ value: ObservableKOf<A>) -> ObservableK<A> {
    return ObservableK.fix(value)
}

extension ForObservableK: Functor {
    public static func map<A, B>(_ fa: Kind<ForObservableK, A>, _ f: @escaping (A) -> B) -> Kind<ForObservableK, B> {
        return ObservableK.fix(fa).value.map(f).k()
    }
}

extension ForObservableK: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForObservableK, A> {
        return Observable.just(a).k()
    }
}

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

extension ForObservableK: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> Kind<ForObservableK, A> {
        return Observable.error(e).k()
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForObservableK, A>, _ f: @escaping (Error) -> Kind<ForObservableK, A>) -> Kind<ForObservableK, A> {
        return ObservableK.fix(fa).value.catchError { e in ObservableK.fix(f(e)).value }.k()
    }
}

extension ForObservableK: MonadError {}

extension ForObservableK: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForObservableK, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return ObservableK.fix(fa).value.reduce(b, accumulator: f).blockingGet()!
    }

    public static func foldRight<A, B>(_ fa: Kind<ForObservableK, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ fa: ObservableK<A>) -> Eval<B> {
            if let get = fa.value.blockingGet() {
                return f(get, Eval.deferEvaluation { loop(fa.value.skip(1).k()) } )
            } else {
                return b
            }
        }
        return Eval.deferEvaluation { loop(ObservableK.fix(fa)) }
    }
}

extension ForObservableK: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForObservableK, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForObservableK, B>> {
        return fa.foldRight(Eval.always { G.pure(Observable<B>.empty().k() as ObservableKOf<B>) }, { a, eval in
            G.map2Eval(f(a), eval, { x, y in
                Observable.concat(Observable.just(x), ObservableK.fix(y).value).k() as ObservableKOf<B>
            })
        }).value()
    }
}

extension ForObservableK: MonadDefer {
    public static func suspend<A>(_ fa: @escaping () -> Kind<ForObservableK, A>) -> Kind<ForObservableK, A> {
        return Observable.deferred { ObservableK<A>.fix(fa()).value }.k()
    }
}

extension ForObservableK: Async {
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

extension ForObservableK: Effect {
    public static func runAsync<A>(_ fa: Kind<ForObservableK, A>, _ callback: @escaping (Either<Error, A>) -> Kind<ForObservableK, ()>) -> Kind<ForObservableK, ()> {
        return ObservableK.fix(fa).value.flatMap { a in ObservableK<()>.fix(callback(Either.right(a))).value }
            .catchError { e in ObservableK<()>.fix(callback(Either.left(e))).value }.k()
    }
}

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
