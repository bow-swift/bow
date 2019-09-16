import Foundation
import Bow

/// MonadDefer is a `Monad` that provides the ability to delay the evaluation of a computation.
public protocol MonadDefer: MonadError {
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter fa: Function returning a computation to be deferred.
    /// - Returns: A computation that defers the execution of the provided function.
    static func `defer`<A>(_ fa: @escaping () -> Kind<Self, A>) -> Kind<Self, A>
}

// MARK: Related functions

public extension MonadDefer {
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter f: Function returning a value.
    /// - Returns: A computation that defers the execution of the provided function.
    static func later<A>(_ f: @escaping () throws -> A) -> Kind<Self, A> {
        return self.defer {
            do {
                return try pure(f())
            } catch {
                return raiseError(error as! E)
            }
        }
    }
    
    /// Provides a computation that evaluates the provided computation on every run.
    ///
    /// - Parameter fa: A value describing a computation to be deferred.
    /// - Returns: A computation that defers the execution of the provided value.
    static func later<A>(_ fa: Kind<Self, A>) -> Kind<Self, A> {
        return self.defer { fa }
    }
    
    /// Provides a lazy computation that returns void.
    ///
    /// - Returns: A deferred computation of the void value.
    static func lazy() -> Kind<Self, ()> {
        return later { }
    }
    
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter f: A function that provides a value or an error.
    /// - Returns: A computation that defers the execution of the provided value.
    static func laterOrRaise<A>(_ f: @escaping () -> Either<E, A>) -> Kind<Self, A> {
        return self.defer { f().fold({ e in self.raiseError(e) },
                                     { a in self.pure(a) }) }
    }
}

// MARK: Syntax for MonadDefer

public extension Kind where F: MonadDefer {
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter fa: Function returning a computation to be deferred.
    /// - Returns: A computation that defers the execution of the provided function.
    static func `defer`(_ fa: @escaping () -> Kind<F, A>) -> Kind<F, A> {
        return F.defer(fa)
    }
    
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Returns: A computation that defers the execution of the provided function.
    static func later(_ f: @escaping () throws -> A) -> Kind<F, A> {
        return F.later(f)
    }
    
    /// Provides a computation that evaluates this computation on every run.
    ///
    /// - Returns: A computation that defers the execution of the provided value.
    func later() -> Kind<F, A> {
        return F.later(self)
    }
    
    /// Provides a lazy computation that returns void.
    ///
    /// - Returns: A deferred computation of the void value.
    static func lazy() -> Kind<F, ()> {
        return F.lazy()
    }
    
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter f: A function that provides a value or an error.
    /// - Returns: A computation that defers the execution of the provided value.
    static func laterOrRaise(_ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
        return F.laterOrRaise(f)
    }
}
