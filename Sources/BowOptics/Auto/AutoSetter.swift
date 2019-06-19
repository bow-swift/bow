/// Protocol for automatic derivation of Setter
public protocol AutoSetter: AutoOptics {}

public extension AutoSetter {
    /// Generates a Setter for the provided field.
    ///
    /// - Parameter path: Key path for the field.
    /// - Returns: A Setter that focuses on the provided field.
    static func setter<T>(for path: WritableKeyPath<Self, T>) -> Setter<Self, T> {
        return Setter<Self, T>(modify: { (whole, f) in
            whole.copy(with: f(whole[keyPath: path]), for: path)
        }, set: { whole, part in
            whole.copy(with: part, for: path)
        })
    }
    
    /// Generates a BoundSetter for the provided field on a specific value.
    ///
    /// - Parameters:
    ///   - path: Key path for the field.
    ///   - value: Value to bind the setter to.
    /// - Returns: A BoundSetter that focuses on the provided field on the specific value.
    static func boundSetter<T>(for path: WritableKeyPath<Self, T>, onValue value: Self) -> BoundSetter<Self, T> {
        return value.boundSetter(for: path)
    }
    
    /// Generates a BoundSetter for the provided field on this value.
    ///
    /// - Parameter path: Key path for the field.
    /// - Returns: A BoundSetter that focuses on the provided field.
    func boundSetter<T>(for path: WritableKeyPath<Self, T>) -> BoundSetter<Self, T> {
        return BoundSetter(value: self, setter: Self.setter(for: path))
    }
}

