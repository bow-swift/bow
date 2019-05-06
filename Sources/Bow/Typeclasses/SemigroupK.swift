import Foundation

/// SemigroupK is a `Semigroup` that operates on kinds with one type parameter.
public protocol SemigroupK {
    /// Combines two values of the same type in the context implementing this instance.
    ///
    /// Implementations of this method must obey the associative law:
    ///
    ///     combineK(fa, combineK(fb, fc)) == combineK(combineK(fa, fb), fc)
    ///
    /// - Parameters:
    ///   - x: Left value in the combination.
    ///   - y: Right value in the combination.
    /// - Returns: Combination of the two values.
    static func combineK<A>(_ x: Kind<Self, A>, _ y: Kind<Self, A>) -> Kind<Self, A>
}

// MARK: Syntax for SemigroupK

public extension Kind where F: SemigroupK {
    /// Combines this value with another value of the same type.
    ///
    /// This is a convenience method to call `SemigroupK.combineK` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - y: Right value in the combination.
    /// - Returns: Combination of the two values.
    func combineK(_ y: Kind<F, A>) -> Kind<F, A> {
        return F.combineK(self, y)
    }
}
