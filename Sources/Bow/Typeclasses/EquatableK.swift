import Foundation

/// EquatableK provides capabilities to check equality of values at the kind level.
public protocol EquatableK {
    /// Checks if two kinds are equal, given that the enclosed value type conforms to `Equatable`.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the equality check.
    ///   - rhs: Right hand side of the equality check.
    /// - Returns: A boolean value indicating if the two values are equal or not.
    static func eq<A: Equatable>(_ lhs: Kind<Self, A>, _ rhs: Kind<Self, A>) -> Bool
}

// MARK: Syntax for EquatableK

public extension Kind where F: EquatableK, A: Equatable {
    /// Checks if two kinds are equal, given that the enclosed value type conforms to `Equatable`.
    ///
    /// This is a convenience method to call `EquatableK.eq` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the equality check.
    ///   - rhs: Right hand side of the equality check.
    /// - Returns: A boolean value indicating if the two values are equal or not.
    public func eq(_ rhs: Kind<F, A>) -> Bool {
        return F.eq(self, rhs)
    }
}

// MARK: Syntax for Equatable

extension Kind: Equatable where F: EquatableK, A: Equatable {
    // Docs inherited from `Equatable`.
    public static func ==(lhs: Kind<F, A>, rhs: Kind<F, A>) -> Bool {
        return F.eq(lhs, rhs)
    }
}
