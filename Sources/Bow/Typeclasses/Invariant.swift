import Foundation

/// An Invariant Functor provides a type the ability to transform its value type into another type. An instance of `Functor` or `Contravariant` are Invariant Functors as well.
public protocol Invariant {
    /// Transforms the value type using the functions provided.
    ///
    /// The implementation of this function must obey the following laws:
    ///
    ///     imap(fa, id, id) == fa
    ///     imap(imap(fa, f1, g1), f2, g2) == imap(fa, compose(f2, f1), compose(g2, g1))
    ///
    /// - Parameters:
    ///   - fa: Value whose value type will be transformed.
    ///   - f: Transforming function.
    ///   - g: Transforming function.
    /// - Returns: A new value in the same context as the original value, with the value type transformed.
    static func imap<A, B>(_ fa : Kind<Self, A>, _ f : @escaping (A) -> B, _ g : @escaping (B) -> A) -> Kind<Self, B>
}

// MARK: Syntax for Invariant

public extension Kind where F: Invariant {
    /// Transforms the value type using the functions provided.
    ///
    /// This is a conveninece method to call `Invariant.imap` as an instance method.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    ///   - g: Transforming function.
    /// - Returns: A new value in the same context as the original value, with the value type transformed.
    func imap<B>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> A) -> Kind<F, B> {
        return F.imap(self, f, g)
    }
}
