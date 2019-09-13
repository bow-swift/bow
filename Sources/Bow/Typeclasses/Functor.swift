import Foundation

/// A Functor provides a type with the ability to transform its value type into another type, while preserving its structure.
///
/// Using the encoding for HKTs in Bow, in the type `Kind<F, A>`, `A` is the value type and `F` represents the structure of the type. An instance of `Functor` for `F` allows to transform `A` into another type, while maintaining `F` unchanged.
public protocol Functor: Invariant {
    /// Creates a new value transforming the type using the provided function, preserving the structure of the original type.
    ///
    /// The implementation of this function must obey two laws:
    ///
    /// 1. Preserve identity:
    ///
    ///         map(fa, id) == fa
    ///
    /// 2. Preserve composition:
    ///
    ///         map(map(fa, f), g) == map(fa, compose(g, f))
    ///
    /// - Parameters:
    ///   - fa: A value in the context of the type implementing this instance of `Functor`.
    ///   - f: A transforming function.
    /// - Returns: The result of transforming the value type using the provided function, maintaining the structure of the original value.
    static func map<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B) -> Kind<Self, B>
}

// MARK: Related functions
public extension Functor {
    // Docs inherited from `Invariant`
    static func imap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (B) -> A) -> Kind<Self, B> {
        return map(fa, f)
    }
    
    /// Creates a new value transforming the type using the provided key path, preserving the structure of the original type.
    ///
    /// - Parameters:
    ///   - fa: A value in the context of the type implementing this instance of `Functor`.
    ///   - keyPath: A key path.
    /// - Returns: The result of transforming the value type using the provided function, maintaining the structure of the original value.
    static func map<A, B>(_ fa: Kind<Self, A>, _ keyPath: KeyPath<A, B>) -> Kind<Self, B> {
        return map(fa, { a in a[keyPath: keyPath] })
    }

    /// Given a function, provides a new function lifted to the context type implementing this instance of `Functor`.
    ///
    /// - Parameter f: Function to be lifted.
    /// - Returns: Function in the context implementing this instance of `Functor`.
    static func lift<A, B>(_ f: @escaping (A) -> B) -> (Kind<Self, A>) -> Kind<Self, B> {
        return { fa in map(fa, f) }
    }

    /// Replaces the value type by the `Void` type.
    ///
    /// - Parameter fa: Value to be transformed.
    /// - Returns: New value in the context implementing this instance of `Functor`, with `Void` as value type.
    static func void<A>(_ fa: Kind<Self, A>) -> Kind<Self, ()> {
        return map(fa, {_ in })
    }

    /// Transforms the value type and pairs it with its original value.
    ///
    /// - Parameters:
    ///   - fa: Value to be transformed.
    ///   - f: Transforming function.
    /// - Returns: A pair with the original value and its transformation, in the context of the original value.
    static func fproduct<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B) -> Kind<Self, (A, B)> {
        return map(fa, { a in (a, f(a)) })
    }

    /// Transforms the value type with a constant value.
    ///
    /// - Parameters:
    ///   - fa: Value to be transformed.
    ///   - b: Constant value to replace the value type.
    /// - Returns: A new value with the structure of the original value, with its value type transformed.
    static func `as`<A, B>(_ fa: Kind<Self, A>, _ b: B) -> Kind<Self, B> {
        return map(fa, { _ in b })
    }

    /// Transforms the value type by making a tuple with a new constant value to the left of the original value type.
    ///
    /// - Parameters:
    ///   - fa: Value to be transformed.
    ///   - b: Constant value for the tuple.
    /// - Returns: A new value with the structure of the original value, with a tuple in its value type.
    static func tupleLeft<A, B>(_ fa: Kind<Self, A>, _ b: B) -> Kind<Self, (B, A)> {
        return map(fa, { a in (b, a) })
    }

    /// Transforms the value type by making a tuple with a new constant value to the right of the original value type.
    ///
    /// - Parameters:
    ///   - fa: Value to be transformed.
    ///   - b: Constant value for the tuple.
    /// - Returns: A new value with the structure of the original value, with a tuple in its value type.
    static func tupleRight<A, B>(_ fa: Kind<Self, A>, _ b: B) -> Kind<Self, (A, B)> {
        return map(fa, { a in (a, b) })
    }
}

// MARK: Syntax for Functor

public extension Kind where F: Functor {
    /// Creates a new value transforming the type using the provided function, preserving the structure of the original type.
    ///
    /// This is a convenience method to call `Functor.map` as an instance method in this type.
    ///
    /// - Parameters:
    ///   - f: A transforming function.
    /// - Returns: The result of transforming the value type using the provided function, maintaining the structure of the original value.
    func map<B>(_ f: @escaping (A) -> B) -> Kind<F, B> {
        return F.map(self, f)
    }
    
    /// Creates a new value transforming the type using the provided key path, preserving the structure of the original type.
    ///
    /// This is a convenience method to call `Functor.map` as an instance method in this type.
    ///
    /// - Parameters:
    ///   - keyPath: A key path.
    /// - Returns: The result of transforming the value type using the provided function, maintaining the structure of the original value.
    func map<B>(_ keyPath: KeyPath<A, B>) -> Kind<F, B> {
        return F.map(self, keyPath)
    }

    /// Given a function, provides a new function lifted to the context type implementing this instance of `Functor`.
    ///
    /// This is a convenience method to call `Functor.lift` as a static method in this type.
    ///
    /// - Parameter f: Function to be lifted.
    /// - Returns: Function in the context implementing this instance of `Functor`.
    static func lift<A, B>(_ f: @escaping (A) -> B) -> (Kind<F, A>) -> Kind<F, B> {
        return { fa in fa.map(f) }
    }

    /// Replaces the value type by the `Void` type.
    ///
    /// This is a convenience method to call `Functor.void` as an instance method of this type.
    ///
    /// - Returns: New value in the context implementing this instance of `Functor`, with `Void` as value type.
    func void() -> Kind<F, ()> {
        return F.void(self)
    }

    /// Transforms the value type and pairs it with its original value.
    ///
    /// This is a conveninence method to call `Functor.fproduct` as an instance method of is type.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    /// - Returns: A pair with the original value and its transformation, in the context of the original value.
    func fproduct<B>(_ f: @escaping (A) -> B) -> Kind<F, (A, B)> {
        return F.fproduct(self, f)
    }

    /// Transforms the value type with a constant value.
    ///
    /// This is a convenience method to call `Functor.as` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - b: Constant value to replace the value type.
    /// - Returns: A new value with the structure of the original value, with its value type transformed.
    func `as`<B>(_ b: B) -> Kind<F, B> {
        return F.as(self, b)
    }

    /// Transforms the value type by making a tuple with a new constant value to the left of the original value type.
    ///
    /// This is a conveninence method to call `Functor.tupleLeft` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - b: Constant value for the tuple.
    /// - Returns: A new value with the structure of the original value, with a tuple in its value type.
    func tupleLeft<B>(_ b: B) -> Kind<F, (B, A)> {
        return F.tupleLeft(self, b)
    }

    /// Transforms the value type by making a tuple with a new constant value to the right of the original value type.
    ///
    /// This is a convenience method to call `Functor.tupleRight` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - b: Constant value for the tuple.
    /// - Returns: A new value with the structure of the original value, with a tuple in its value type.
    func tupleRight<B>(_ b: B) -> Kind<F, (A, B)> {
        return F.tupleRight(self, b)
    }
}
