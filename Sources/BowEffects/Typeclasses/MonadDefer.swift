import Foundation
import Bow

public protocol MonadDefer: MonadError {
    static func suspend<A>(_ fa: @escaping () -> Kind<Self, A>) -> Kind<Self, A>
}

public extension MonadDefer {
    static func delay<A>(_ f: @escaping () throws -> A) -> Kind<Self, A> {
        return self.suspend {
            do {
                return try pure(f())
            } catch {
                return raiseError(error as! E)
            }
        }
    }

    static func lazy() -> Kind<Self, ()> {
        return delay {}
    }

    static func delayEither<A>(_ f: @escaping () -> Either<E, A>) -> Kind<Self, A> {
        return self.suspend { f().fold({ e in self.raiseError(e) },
                                       { a in self.pure(a) }) }
    }
}

// MARK: Syntax for MonadDefer

public extension Kind where F: MonadDefer {
    static func suspend(_ fa: @escaping () -> Kind<F, A>) -> Kind<F, A> {
        return F.suspend(fa)
    }

    static func delay(_ f: @escaping () throws -> A) -> Kind<F, A> {
        return F.delay(f)
    }

    static func lazy() -> Kind<F, ()> {
        return F.lazy()
    }

    static func delayEither(_ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
        return F.delayEither(f)
    }
}
