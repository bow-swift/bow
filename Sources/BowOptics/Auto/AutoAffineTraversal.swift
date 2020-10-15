import Bow

/// Protocol for automatic derivation of AffineTraversal optics.
public protocol AutoAffineTraversal: AutoOptics {}

public extension AutoAffineTraversal {
    /// Generates an AffineTraversal optic that focuses on a nilable field.
    ///
    /// - Parameter path: Key path to a nilable field.
    /// - Returns: An AffineTraversal optic focusing on the provided field.
    static func affineTraversal<T>(for path: WritableKeyPath<Self, T?>) -> AffineTraversal<Self, T> {
        return AffineTraversal<Self, T>(set: { whole, part in whole.copy(with: part, for: path) },
                                 getOrModify: { whole in Option.fromOptional(whole[keyPath: path])
                                    .fold({ Either.left(whole) }, Either.right) })
    }
    
    /// Generates an AffineTraversal optic that focuses on an Option field.
    ///
    /// - Parameter path: Key path to an Option field.
    /// - Returns: An AffineTraversal optic focusing on the provided field.
    static func affineTraversal<T>(for path: WritableKeyPath<Self, Option<T>>) -> AffineTraversal<Self, T> {
        return AffineTraversal<Self, T>(set: { whole, part in whole.copy(with: .some(part), for: path) },
                                 getOrModify: { whole in whole[keyPath: path]
                                    .fold({ Either.left(whole) }, Either.right) })
    }
}
