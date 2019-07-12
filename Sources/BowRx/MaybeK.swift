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

    public static func from(_ f: @escaping () -> A) -> MaybeK<A> {
        return MaybeK.fix(suspend { MaybeK.fix(pure(f())) })
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

extension ForMaybeK: Functor {
    public static func map<A, B>(_ fa: Kind<ForMaybeK, A>, _ f: @escaping (A) -> B) -> Kind<ForMaybeK, B> {
        return MaybeK.fix(fa).value.map(f).k()
    }
}

extension ForMaybeK: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForMaybeK, A> {
        return Maybe.just(a).k()
    }
}

// MARK: Instance of `Selective` for `MaybeK`
extension ForMaybeK: Selective {}

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

extension ForMaybeK: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForMaybeK, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return MaybeK.fix(fa).fold(constant(b), { a in f(b, a) })
    }

    public static func foldRight<A, B>(_ fa: Kind<ForMaybeK, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Eval.`defer` { MaybeK.fix(fa).fold(constant(b), { a in f(a, b) }) }
    }
}

extension ForMaybeK: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> Kind<ForMaybeK, A> {
        return Maybe.error(e).k()
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForMaybeK, A>, _ f: @escaping (Error) -> Kind<ForMaybeK, A>) -> Kind<ForMaybeK, A> {
        return MaybeK.fix(fa).value.catchError { e in MaybeK.fix(f(e)).value }.k()
    }
}

extension ForMaybeK: MonadError {}

extension ForMaybeK: MonadDefer {
    public static func suspend<A>(_ fa: @escaping () -> Kind<ForMaybeK, A>) -> Kind<ForMaybeK, A> {
        return Maybe.deferred { MaybeK<A>.fix(fa()).value }.k()
    }
}

extension ForMaybeK: Async {
    public static func runAsync<A>(_ fa: @escaping (@escaping(Either<Error, A>) -> ()) throws -> ()) -> Kind<ForMaybeK, A> {
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

extension ForMaybeK: Effect {
    public static func runAsync<A>(_ fa: Kind<ForMaybeK, A>, _ callback: @escaping (Either<ForMaybeK.E, A>) -> Kind<ForMaybeK, ()>) -> Kind<ForMaybeK, ()> {
        return MaybeK<A>.fix(fa).runAsync(callback)
    }
}
