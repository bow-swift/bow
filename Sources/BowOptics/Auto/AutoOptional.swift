import Bow

/// Protocol for automatic derivation of Optional optics.
public protocol AutoOptional: AutoOptics {}

public extension AutoOptional {
    /// Generates an Optional optic that focuses on a nilable field.
    ///
    /// - Parameter path: Key path to a nilable field.
    /// - Returns: An Optional optic focusing on the provided field.
    static func optional<T>(for path: WritableKeyPath<Self, T?>) -> Optional<Self, T> {
        return Optional<Self, T>(set: { whole, part in whole.copy(with: part, for: path) },
                                 getOrModify: { whole in Option.fromOptional(whole[keyPath: path])
                                    .fold({ Either.left(whole) }, Either.right) })
    }
    
    /// Generates an Optional optic that focuses on an Option field.
    ///
    /// - Parameter path: Key path to an Option field.
    /// - Returns: An Optional optic focusing on the provided field.
    static func optional<T>(for path: WritableKeyPath<Self, Option<T>>) -> Optional<Self, T> {
        return Optional<Self, T>(set: { whole, part in whole.copy(with: .some(part), for: path) },
                                 getOrModify: { whole in whole[keyPath: path]
                                    .fold({ Either.left(whole) }, Either.right) })
    }
}
