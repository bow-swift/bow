import Foundation
import Bow

public protocol MonadDefer: MonadError where E: Error {
    static func suspend<A>(_ fa: @escaping () -> Kind<Self, A>) -> Kind<Self, A>
}

public extension MonadDefer {
    public static func delay<A>(_ f: @escaping () throws -> A) -> Kind<Self, A> {
        return self.suspend {
            do {
                return try pure(f())
            } catch {
                return raiseError(error as! E)
            }
        }
    }
    
    public static func lazy() -> Kind<Self, ()> {
        return delay {}
    }
    
    public static func delayEither<A>(_ f: @escaping () -> Either<E, A>) -> Kind<Self, A> {
        return self.suspend { f().fold({ e in self.raiseError(e) },
                                       { a in self.pure(a) }) }
    }
}

public extension Kind where F: MonadDefer {
    public static func suspend(_ fa: @escaping () -> Kind<F, A>) -> Kind<F, A> {
        return F.suspend(fa)
    }

    public static func delay(_ f: @escaping () throws -> A) -> Kind<F, A> {
        return F.delay(f)
    }

    public static func lazy() -> Kind<F, ()> {
        return F.lazy()
    }

    public static func delayEither(_ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
        return F.delayEither(f)
    }
}
