import Foundation

/// A MonoidK is a `SemigroupK` that also has an empty element.
public protocol MonoidK: SemigroupK {
    /// Empty element.
    ///
    /// This element must obey the following laws:
    ///
    ///     combineK(fa, emptyK()) == combineK(emptyK(), fa) == fa
    ///
    /// - Returns: A value representing the empty element of this MonoidK instance.
    static func emptyK<A>() -> Kind<Self, A>
}

// MARK: Syntax for MonoidK

public extension Kind where F: MonoidK {
    /// Empty element.
    ///
    /// This element must obey the following laws:
    ///
    ///     combineK(fa, emptyK()) == combineK(emptyK(), fa) == fa
    ///
    /// This is a convenience method to call `MonoidK.emptyK` as a static method of this type.
    ///
    /// - Returns: A value representing the empty element of this MonoidK instance.
    static func emptyK() -> Kind<F, A> {
        return F.emptyK()
    }
}
