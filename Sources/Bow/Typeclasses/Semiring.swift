import Foundation

/// A semiring is an algebraic structure that has the same properties as a commutative monoid for addition, with multiplication.
public protocol Semiring: Monoid {
    /// An associative operation to combine values of the implementing type.
    ///
    /// This operation must satisfy the semigroup laws:
    ///
    ///     a.multiply(b).multiply(c) == a.multiply(b.multiply(c))
    ///
    /// - Parameter other: Value to multipy with the receiver.
    /// - Returns: Multiplication of the receiver value with the parameter value.
    func multiply(_ other: Self) -> Self
    
    /// Zero element.
    ///
    /// The zero element must obey the semirings laws:
    ///
    ///     a.multiply(zero()) == zero().multiply(a) == zero()
    ///
    /// That is, multiplying any element with `zero` must return the `zero`.
    /// It is also an alias for `empty` of `Monoid`.
    ///
    /// - Returns: A value of the implementing type satisfying the semiring laws.
    static func zero() -> Self
    
    /// One element.
    ///
    /// The one element must obey the semirings laws:
    ///
    ///     a.multiply(one()) == one().multiply(a) == a
    ///
    /// That is, multiplying any element with `one` must return the original element.
    ///
    /// - Returns: A value of the implementing type satisfying the semiring laws.
    static func one() -> Self
}

public extension Semiring {
    static func zero() -> Self { Self.empty() }
}
