import Foundation

/// A Contravariant Functor is the dual of a Covariant Functor, usually referred to as just `Functor`. Whereas an intuition behind Covariant Functors is that they can be seen as containing or producing values, Contravariant Functors can be seen as consuming values.
public protocol Contravariant: Invariant {
    /// Creates a new value transforming the type using the provided function, preserving the structure of the original type.
    ///
    /// - Parameters:
    ///   - fa: Value to be transformed.
    ///   - f: Transforming function.
    /// - Returns: The result of transforming the value type using the provided function, maintaining the structure of the original value.
    static func contramap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (B) -> A) -> Kind<Self, B>
}

public extension Contravariant {
    // Docs inherited from `Invariant`.
    static func imap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (B) -> A) -> Kind<Self, B> {
        return contramap(fa, g)
    }

    /// Given a function, provides a new function lifted to the context type implementing this instance of `Contravariant`, but reversing the direction of the arrow.
    ///
    /// - Parameter f: Function to be lifted.
    /// - Returns: Function in the context implementing this instance.
    static func contralift<A, B>(_ f: @escaping (A) -> B) -> (Kind<Self, B>) -> Kind<Self, A> {
        return { fa in contramap(fa, f) }
    }
}

// MARK: Syntax for Contravariant

public extension Kind where F: Contravariant {
    /// Creates a new value transforming the type using the provided function, preserving the structure of the original type.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    /// - Returns: The result of transforming the value type using the provided function, maintaining the structure of the original value.
    func contramap<B>(_ f : @escaping (B) -> A) -> Kind<F, B> {
        return F.contramap(self, f)
    }

    /// Given a function, provides a new function lifted to the context type implementing this instance of `Contravariant`, but reversing the direction of the arrow.
    ///
    /// - Parameter f: Function to be lifted.
    /// - Returns: Function in the context implementing this instance.
    static func contralift<B>(_ f : @escaping (A) -> B) -> (Kind<F, B>) -> Kind<F, A> {
        return F.contralift(f)
    }
}
