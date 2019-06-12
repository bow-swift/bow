/// Base protocol for optics automatic derivation.
public protocol AutoOptics {}

public extension AutoOptics {
    /// Creates a copy of this object, replacing the value at the given key path by the provided value.
    ///
    /// - Parameters:
    ///   - value: New value for the field in the copy.
    ///   - path: Key path of the field that will be modified in the copy.
    /// - Returns: A copy of this value with the modified field.
    func copy<T>(with value: T, for path: WritableKeyPath<Self, T>) -> Self {
        var copy = self
        copy[keyPath: path] = value
        return copy
    }
}
