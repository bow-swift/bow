import Bow

/// Protocol for automatic derivation of Traversal
public protocol AutoTraversal: AutoLens {}

public extension AutoTraversal {
    /// Provides a Traversal focused on the items of the field given by a key path.
    ///
    /// - Parameter path: Key path to a field containing an array of items.
    /// - Returns: A Traversal focused on the items of the field.
    static func traversal<T>(for path: WritableKeyPath<Self, Array<T>>) -> Traversal<Self, T> {
        return Self.lens(for: path) + Array<T>.traversal
    }
    
    /// Provides a Traversal focused on the items of the field given by a key path.
    ///
    /// - Parameter path: Key path to a field containing an `ArrayK` of items.
    /// - Returns: A Traversal focused on the items of the field.
    static func traversal<T>(for path: WritableKeyPath<Self, ArrayK<T>>) -> Traversal<Self, T> {
        return Self.lens(for: path) + ArrayK<T>.traversal
    }
    
    /// Provides a Traversal focused on the items of the field given by a key path.
    ///
    /// - Parameter path: Key path to a field of a type with an instance of `Traverse`.
    /// - Returns: A Traversal focused on the items of the `Traverse` structure.
    static func traversal<T, F: Traverse>(for path: WritableKeyPath<Self, Kind<F, T>>) -> Traversal<Self, T> {
        return Self.lens(for: path) + Kind<F, T>.traversalK
    }
}
