import Foundation
import BrightFutures
import Bow
import BowEffects

public final class ForFutureK {}
public final class FutureKPartial<E: Error>: Kind<ForFutureK, E> {}
public typealias FutureKOf<E: Error, A> = Kind<FutureKPartial<E>, A>

public extension Future {
    func k() -> FutureK<E, T> {
        return FutureK(self)
    }
}

public class FutureK<E: Error, A>: FutureKOf<E, A> {
    public let value: Future<A, E>

    public static func fix(_ value : FutureKOf<E, A>) -> FutureK<E, A> {
        return value as! FutureK<E, A>
    }

    public static func raiseError(_ e : E) -> FutureK<E, A> {
        return Future(error: e).k()
    }

    public static func from(_ f : @escaping () -> A) -> FutureK<E, A> {
        return Future { complete in complete(.success(f())) }.k()
    }

    public static func runAsync(_ fa : @escaping ((Either<E, A>) -> ()) throws -> ()) -> FutureK<E, A> {
        return Future { complete in
            do {
                try fa { either in
                    either.fold({ e in complete(.failure(e)) },
                                { a in complete(.success(a)) })
                }
            } catch {}
            }.k()
    }

    public init(_ value: Future<A, E>) {
        self.value = value
    }

    public var isCompleted : Bool {
        return value.isCompleted
    }

    public var isSuccess: Bool {
        return value.isSuccess
    }

    public var isFailure: Bool {
        return value.isFailure
    }

    public func runAsync(_ callback : @escaping (Either<E, A>) -> FutureKOf<E, ()>) -> FutureK<E, ()> {
        return value.flatMap { a in FutureK<E, ()>.fix(callback(Either.right(a))).value }
            .recoverWith { e in FutureK<E, ()>.fix(callback(Either.left(e))).value }.k()
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to FutureK.
public postfix func ^<E, A>(_ value: FutureKOf<E, A>) -> FutureK<E, A> {
    return FutureK.fix(value)
}

extension FutureKPartial: Functor {
    public static func map<A, B>(_ fa: Kind<FutureKPartial<E>, A>, _ f: @escaping (A) -> B) -> Kind<FutureKPartial<E>, B> {
        return FutureK.fix(fa).value.map(environmentContext(), f: f).k()
    }
}

extension FutureKPartial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<FutureKPartial<E>, A> {
        return Future(value: a).k()
    }
}

// MARK: Instance of `Selective` for `FutureK`
extension FutureKPartial: Selective {}

extension FutureKPartial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<FutureKPartial<E>, A>, _ f: @escaping (A) -> Kind<FutureKPartial<E>, B>) -> Kind<FutureKPartial<E>, B> {
        return FutureK.fix(fa).value.flatMap(environmentContext()) { a in FutureK.fix(f(a)).value }.k()
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<FutureKPartial<E>, Either<A, B>>) -> Kind<FutureKPartial<E>, B> {
        let either = FutureK<E, Either<A, B>>.fix(f(a)).value.value!
        return either.fold({ a in tailRecM(a, f) },
                           { b in FutureK.pure(b) })
    }
}

extension FutureKPartial: ApplicativeError {
    public static func raiseError<A>(_ e: E) -> Kind<FutureKPartial<E>, A> {
        return Future(error: e).k()
    }

    public static func handleErrorWith<A>(_ fa: Kind<FutureKPartial<E>, A>, _ f: @escaping (E) -> Kind<FutureKPartial<E>, A>) -> Kind<FutureKPartial<E>, A> {
        return FutureK.fix(fa).value.recoverWith(context: environmentContext()) { e in FutureK<E, A>.fix(f(e)).value }.k()
    }
}

extension FutureKPartial: MonadError {}

extension FutureKPartial: MonadDefer {
    public static func suspend<A>(_ fa: @escaping () -> Kind<FutureKPartial<E>, A>) -> Kind<FutureKPartial<E>, A> {
        return FutureK.pure(()).flatMap(fa)
    }
}

extension FutureKPartial: BowEffects.Async {
    public static func runAsync<A>(_ fa: @escaping ((Either<E, A>) -> ()) throws -> ()) -> Kind<FutureKPartial<E>, A> {
        return Future { complete in
            do {
                try fa { either in
                    either.fold({ e in complete(.failure(e)) },
                                { a in complete(.success(a)) })
                }
            } catch {}
            }.k()
    }
}

extension FutureKPartial: Effect {
    public static func runAsync<A>(_ fa: Kind<FutureKPartial<E>, A>, _ callback: @escaping (Either<E, A>) -> Kind<FutureKPartial<E>, ()>) -> Kind<FutureKPartial<E>, ()> {
        return FutureK<E, A>.fix(fa).value
            .flatMap(environmentContext()) { a in FutureK<E, ()>.fix(callback(Either.right(a))).value }
            .recoverWith(context: environmentContext()) { e in FutureK<E, ()>.fix(callback(Either.left(e))).value }.k()
    }
}

private func environmentContext() -> ExecutionContext {
    return isTesting() ? ImmediateOnMainExecutionContext : DefaultThreadingModel()
}

private func isTesting() -> Bool {
    return ProcessInfo().environment["BOW_BRIGHT_FUTURES_TEST"] == "YES"
}
