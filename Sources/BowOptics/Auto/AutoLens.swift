/// Protocol for automatic derivation of lenses.
public protocol AutoLens: AutoOptics {}

public extension AutoLens {
    /// Generates a Lens for the field indicated by its key path.
    ///
    /// - Parameter path: Key path identifying the field where the Lens focuses.
    /// - Returns: A Lens focusing in the field.
    static func lens<T>(for path: WritableKeyPath<Self, T>) -> Lens<Self, T> {
        return Lens<Self, T>(get: { whole in whole[keyPath: path] },
                             set: { whole, part in whole.copy(with: part, for: path) })
    }
}
