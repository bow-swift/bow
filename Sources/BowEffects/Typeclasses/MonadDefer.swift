import Foundation
import Bow

public protocol MonadDefer: Bracket {
    static func `defer`<A>(_ fa: @escaping () -> Kind<Self, A>) -> Kind<Self, A>
}

// MARK: Related functions

public extension MonadDefer {
    static func delay<A>(_ f: @escaping () throws -> A) -> Kind<Self, A> {
        return self.defer {
            do {
                return try pure(f())
            } catch {
                return raiseError(error as! E)
            }
        }
    }
    
    static func delay<A>(_ fa: Kind<Self, A>) -> Kind<Self, A> {
        return self.defer(constant(fa))
    }
    
    static func lazy() -> Kind<Self, ()> {
        return delay {}
    }
    
    static func delayOrRaise<A>(_ f: @escaping () -> Either<E, A>) -> Kind<Self, A> {
        return self.defer { f().fold({ e in self.raiseError(e) },
                                     { a in self.pure(a) }) }
    }
}

// MARK: Syntax for MonadDefer

public extension Kind where F: MonadDefer {
    static func suspend(_ fa: @escaping () -> Kind<F, A>) -> Kind<F, A> {
        return F.defer(fa)
    }
    
    func delay(_ f: @escaping () throws -> A) -> Kind<F, A> {
        return F.delay(f)
    }
    
    func delay() -> Kind<F, A> {
        return F.delay(self)
    }
    
    static func lazy() -> Kind<F, ()> {
        return F.lazy()
    }
    
    static func delayOrRaise(_ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
        return F.delayOrRaise(f)
    }
}
