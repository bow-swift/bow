import Foundation
import Bow

public protocol MonadDefer: MonadError {
    static func `defer`<A>(_ fa: @escaping () -> Kind<Self, A>) -> Kind<Self, A>
}

// MARK: Related functions

public extension MonadDefer {
    static func later<A>(_ f: @escaping () throws -> A) -> Kind<Self, A> {
        return self.defer {
            do {
                return try pure(f())
            } catch {
                return raiseError(error as! E)
            }
        }
    }
    
    static func later<A>(_ fa: Kind<Self, A>) -> Kind<Self, A> {
        return self.defer { fa }
    }
    
    static func lazy() -> Kind<Self, ()> {
        return later { }
    }
    
    static func laterOrRaise<A>(_ f: @escaping () -> Either<E, A>) -> Kind<Self, A> {
        return self.defer { f().fold({ e in self.raiseError(e) },
                                     { a in self.pure(a) }) }
    }
}

// MARK: Syntax for MonadDefer

public extension Kind where F: MonadDefer {
    static func `defer`(_ fa: @escaping () -> Kind<F, A>) -> Kind<F, A> {
        return F.defer(fa)
    }
    
    func later(_ f: @escaping () throws -> A) -> Kind<F, A> {
        return F.later(f)
    }
    
    func later() -> Kind<F, A> {
        return F.later(self)
    }
    
    static func lazy() -> Kind<F, ()> {
        return F.lazy()
    }
    
    static func laterOrRaise(_ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
        return F.laterOrRaise(f)
    }
}
