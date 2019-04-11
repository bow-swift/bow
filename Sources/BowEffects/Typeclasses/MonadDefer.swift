import Foundation
import Bow

public protocol MonadDefer: Bracket {
    static func `defer`<A>(_ fa: @escaping () -> Kind<Self, A>) -> Kind<Self, A>
}

// MARK: Related functions

public extension MonadDefer {
    public static func delay<A>(_ f: @escaping () throws -> A) -> Kind<Self, A> {
        return self.defer {
            do {
                return try pure(f())
            } catch {
                return raiseError(error as! E)
            }
        }
    }

    public static func delay<A>(_ fa: Kind<Self, A>) -> Kind<Self, A> {
        return self.defer(constant(fa))
    }
    
    public static func lazy() -> Kind<Self, ()> {
        return delay {}
    }
    
    public static func delayOrRaise<A>(_ f: @escaping () -> Either<E, A>) -> Kind<Self, A> {
        return self.defer { f().fold({ e in self.raiseError(e) },
                                     { a in self.pure(a) }) }
    }
}

// MARK: Syntax for MonadDefer

public extension Kind where F: MonadDefer {
    public static func suspend(_ fa: @escaping () -> Kind<F, A>) -> Kind<F, A> {
        return F.defer(fa)
    }

    public static func delay(_ f: @escaping () throws -> A) -> Kind<F, A> {
        return F.delay(f)
    }

    public func delay() -> Kind<F, A> {
        return F.delay(self)
    }

    public static func lazy() -> Kind<F, ()> {
        return F.lazy()
    }

    public static func delayOrRaise(_ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
        return F.delayOrRaise(f)
    }
}
