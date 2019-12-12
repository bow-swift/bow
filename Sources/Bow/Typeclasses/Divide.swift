/// Divide is a type class that models the divide part of divide and conquer.
public protocol Divide: Contravariant {
    /// Takes two computations and provides a computation using a function that specifies how to divide the returned type into the two provided types.
    /// - Parameter fa: 1st computation.
    /// - Parameter fb: 2nd computation.
    /// - Parameter f: Dividing function.
    /// - Returns: A computation that merges the divided parts.
    static func divide<A, B, C>(_ fa: Kind<Self, A>, _ fb: Kind<Self, B>, _ f: (C) -> (A, B)) -> Kind<Self, C>
}

// MARK: Syntax for Divide
public extension Kind where F: Divide {
    /// Takes a computation and provides a computation using a function that specifies how to divide the returned type into the two provided types.
    /// - Parameter fb: 2nd computation.
    /// - Parameter f: Dividing function.
    /// - Returns: A computation that merges the divided parts.
    func divide<B, C>(_ fb: Kind<F, B>, _ f: (C) -> (A, B)) -> Kind<F, C> {
        F.divide(self, fb, f)
    }
}
