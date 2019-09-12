import Foundation
import RxSwift
import Bow
import BowEffects

public final class ForMaybeK {}
public typealias MaybeKOf<A> = Kind<ForMaybeK, A>

public extension PrimitiveSequence where Trait == MaybeTrait {
    func k() -> MaybeK<Element> {
        return MaybeK(self)
    }
}

public final class MaybeK<A>: MaybeKOf<A> {
    public let value: Maybe<A>

    public static func fix(_ value: MaybeKOf<A>) -> MaybeK<A> {
        return value as! MaybeK<A>
    }

    public static func from(_ f: @escaping () throws -> A) -> MaybeK<A> {
        return ForMaybeK.defer {
            do {
                return pure(try f())
            } catch {
                return raiseError(error)
            }
        }^
    }
    
    public static func invoke(_ f: @escaping () throws -> MaybeKOf<A>) -> MaybeK<A> {
        return ForMaybeK.defer {
            do {
                return try f()
            } catch {
                return raiseError(error)
            }
        }^
    }

    public init(_ value: Maybe<A>) {
        self.value = value
    }

    public func fold<B>(_ ifEmpty: @escaping () -> B, _ ifSome: @escaping (A) -> B) -> B {
        if let result = value.blockingGet() {
            return ifSome(result)
        } else {
            return ifEmpty()
        }
    }

    public func runAsync(_ callback: @escaping (Either<Error, A>) -> MaybeKOf<()>) -> MaybeK<()> {
        return value.flatMap { a in MaybeK<()>.fix(callback(Either.right(a))).value }
            .catchError { e in MaybeK<()>.fix(callback(Either.left(e))).value }.k()
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to MaybeK.
public postfix func ^<A>(_ value: MaybeKOf<A>) -> MaybeK<A> {
    return MaybeK.fix(value)
}

// MARK: Instance of `Functor` for `MaybeK`
extension ForMaybeK: Functor {
    public static func map<A, B>(_ fa: Kind<ForMaybeK, A>, _ f: @escaping (A) -> B) -> Kind<ForMaybeK, B> {
        return MaybeK.fix(fa).value.map(f).k()
    }
}

// MARK: Instance of `Applicative` for `MaybeK`
extension ForMaybeK: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForMaybeK, A> {
        return Maybe.just(a).k()
    }
}

// MARK: Instance of `Selective` for `MaybeK`
extension ForMaybeK: Selective {}

// MARK: Instance of `Monad` for `MaybeK`
extension ForMaybeK: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForMaybeK, A>, _ f: @escaping (A) -> Kind<ForMaybeK, B>) -> Kind<ForMaybeK, B> {
        return MaybeK.fix(fa).value.flatMap { a in MaybeK<B>.fix(f(a)).value }.k()
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForMaybeK, Either<A, B>>) -> Kind<ForMaybeK, B> {
        let either = MaybeK.fix(f(a)).value.blockingGet()!
        return either.fold({ a in tailRecM(a, f) },
                           { b in Maybe.just(b).k() })
    }
}

// MARK: Instance of `Foldable` for `MaybeK`
extension ForMaybeK: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForMaybeK, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return MaybeK.fix(fa).fold(constant(b), { a in f(b, a) })
    }

    public static func foldRight<A, B>(_ fa: Kind<ForMaybeK, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Eval.defer { MaybeK.fix(fa).fold(constant(b), { a in f(a, b) }) }
    }
}

// MARK: Instance of `ApplicativeError` for `MaybeK`
extension ForMaybeK: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> Kind<ForMaybeK, A> {
        return Maybe.error(e).k()
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForMaybeK, A>, _ f: @escaping (Error) -> Kind<ForMaybeK, A>) -> Kind<ForMaybeK, A> {
        return MaybeK.fix(fa).value.catchError { e in MaybeK.fix(f(e)).value }.k()
    }
}

// MARK: Instance of `MonadError` for `MaybeK`
extension ForMaybeK: MonadError {}

// MARK: Instance of `MonadDefer` for `MaybeK`
extension ForMaybeK: MonadDefer {
    public static func `defer`<A>(_ fa: @escaping () -> Kind<ForMaybeK, A>) -> Kind<ForMaybeK, A> {
        return Maybe.deferred { fa()^.value }.k()
    }
}

// MARK: Instance of `Async` for `MaybeK`
extension ForMaybeK: Async {
    public static func asyncF<A>(_ procf: @escaping (@escaping (Either<Error, A>) -> ()) -> Kind<ForMaybeK, ()>) -> Kind<ForMaybeK, A> {
        return Maybe<A>.create { emitter in
            return procf { either in
                either.fold(
                    { error in emitter(.error(error)) },
                    { value in emitter(.success(value)) })
            }^.value.subscribe(onError: { e in emitter(.error(e)) })
        }.k()
    }
    
    public static func continueOn<A>(_ fa: Kind<ForMaybeK, A>, _ queue: DispatchQueue) -> Kind<ForMaybeK, A> {
        return fa^.value.observeOn(SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: queue.label)).k()
    }
    
    public static func runAsync<A>(_ fa: @escaping ((Either<Error, A>) -> ()) throws -> ()) -> Kind<ForMaybeK, A> {
        return Maybe.create { emitter in
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
extension ForMaybeK: Effect {
    public static func runAsync<A>(_ fa: Kind<ForMaybeK, A>, _ callback: @escaping (Either<ForMaybeK.E, A>) -> Kind<ForMaybeK, ()>) -> Kind<ForMaybeK, ()> {
        return MaybeK<A>.fix(fa).runAsync(callback)
    }
}

// MARK: Instance of `Concurrent` for `MaybeK`
extension ForMaybeK: Concurrent {
    public static func parMap<A, B, Z>(_ fa: Kind<ForMaybeK, A>, _ fb: Kind<ForMaybeK, B>, _ f: @escaping (A, B) -> Z) -> Kind<ForMaybeK, Z> {
        return Maybe.zip(fa^.value, fb^.value, resultSelector: f).k()
    }
    
    public static func parMap<A, B, C, Z>(_ fa: Kind<ForMaybeK, A>, _ fb: Kind<ForMaybeK, B>, _ fc: Kind<ForMaybeK, C>, _ f: @escaping (A, B, C) -> Z) -> Kind<ForMaybeK, Z> {
        return Maybe.zip(fa^.value, fb^.value, fc^.value, resultSelector: f).k()
    }
}

// MARK: Instance of `Bracket` for `MaybeK`
extension ForMaybeK: Bracket {
    public static func bracketCase<A, B>(
        acquire fa: Kind<ForMaybeK, A>,
        release: @escaping (A, ExitCase<Error>) -> Kind<ForMaybeK, ()>,
        use: @escaping (A) throws -> Kind<ForMaybeK, B>) -> Kind<ForMaybeK, B> {
        return Maybe.create { emitter in
            return fa.handleErrorWith { t in MaybeK.from { emitter(.error(t)) }.value.flatMap { Maybe.error(t) }.k() }
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
