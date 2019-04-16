import Foundation

/// A Comonad is the dual of a `Monad`. It provides capabilities to compose functions that extract values from their context.
///
/// Implementations of this instance must obey the following laws:
///
///     extract(duplicate(fa)) == fa
///     map(fa, f) == coflatMap(fa, { a in f(extract(a)) }
///     coflatMap(fa, extract) == fa
///     extract(coflatMap(fa, f)) == f(fa)
///
public protocol Comonad: Functor {
    /// Applies a value in the context implementing this instance to a function that takes a value in a context, and returns a normal value.
    ///
    /// This function is the dual of `Monad.flatMap`.
    ///
    /// - Parameters:
    ///   - fa: Value in the context implementing this instance.
    ///   - f: Extracting function.
    /// - Returns: The result of extracting and transforming the value, in the context implementing this instance.
    static func coflatMap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (Kind<Self, A>) -> B) -> Kind<Self, B>

    /// Extracts the value contained in the context implementing this instance.
    ///
    /// This function is the dual of `Monad.pure` (via `Applicative`).
    ///
    /// - Parameter fa: A value in the context implementing this instance.
    /// - Returns: A normal value.
    static func extract<A>(_ fa: Kind<Self, A>) -> A
}

// MARK: Related functions

public extension Comonad {
    /// Wraps a value in another layer of the context implementing this instance.
    ///
    /// - Parameter fa: A value in the context implementing this instance.
    /// - Returns: Value wrapped in another context layer.
    static func duplicate<A>(_ fa: Kind<Self, A>) -> Kind<Self, Kind<Self, A>> {
        return coflatMap(fa, id)
    }
}

// MARK: Syntax for Comonad

public extension Kind where F: Comonad {
    /// Applies this value to a function that takes a value in this context, and returns a normal value.
    ///
    /// This function is the dual of `Monad.flatMap`.
    ///
    /// This is a convenience function to call `Comonad.coflatMap` as an instance method.
    ///
    /// - Parameters:
    ///   - f: Extracting function.
    /// - Returns: The result of extracting and transforming the value, in the context implementing this instance.
    func coflatMap<B>(_ f: @escaping (Kind<F, A>) -> B) -> Kind<F, B> {
        return F.coflatMap(self, f)
    }

    /// Extracts the value contained in this context.
    ///
    /// This function is the dual of `Monad.pure` (via `Applicative`).
    ///
    /// This is a convenience function to call `Comonad.extract` as an instance method.
    ///
    /// - Returns: A normal value.
    func extract() -> A {
        return F.extract(self)
    }

    /// Wraps this in another layer of this context.
    ///
    /// - Returns: This value wrapped in another context layer.
    func duplicate() -> Kind<F, Kind<F, A>> {
        return F.duplicate(self)
    }
}
