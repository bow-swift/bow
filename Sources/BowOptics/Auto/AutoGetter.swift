/// Protocol for automatic derivation of Getter optics
public protocol AutoGetter: AutoOptics {}

public extension AutoGetter {
    /// Generates a Getter for the field given by the key path.
    ///
    /// - Parameter path: Key path of the field.
    /// - Returns: A Getter optic focused on the provided field.
    static func getter<T>(for path: KeyPath<Self, T>) -> Getter<Self, T> {
        return Getter(get: { whole in whole[keyPath: path] })
    }
}
