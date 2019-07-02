import Bow

/// Protocol for automatic Fold derivation
public protocol AutoFold: AutoLens {}

public extension AutoFold {
    /// Provides a Fold focused on the items of the field given by a key path.
    ///
    /// - Parameter path: Key path to a field containing an array of items.
    /// - Returns: A Fold optic focused on the items of the specified field.
    static func fold<T>(for path: WritableKeyPath<Self, Array<T>>) -> Fold<Self, T> {
        return Self.lens(for: path) + Array<T>.fold
    }
    
    /// Provides a Fold focused on the items of the field given by a key path.
    ///
    /// - Parameter path: Key path to a field containing an `ArrayK` of items.
    /// - Returns: A Fold optic focused on the items of the specified field.
    static func fold<T>(for path: WritableKeyPath<Self, ArrayK<T>>) -> Fold<Self, T> {
        return Self.lens(for: path) + ArrayK<T>.fold
    }
    
    /// Provides a Fold focused on the items of a `Foldable` field given by a key path.
    ///
    /// - Parameter path: Key path to a field of a type with an instance of `Foldable`.
    /// - Returns: A Fold optic focused on the item wrapped in a `Foldable`.
    static func fold<T, F: Foldable>(for path: WritableKeyPath<Self, Kind<F, T>>) -> Fold<Self, T> {
        return Self.lens(for: path) + Kind<F, T>.foldK
    }
}
