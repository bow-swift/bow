import Foundation

    /// Instance of `Semigroup` for `Bool`. Uses conjunction as combination of elements.
    ///
    /// Use `Bool.andSemigroup` to obtain an instance of this type.
extension Bool: Semigroup {
    public func combine(_ other: Bool) -> Bool {
        return self && other
    }
}

    /// Instance of `Monoid` for `Bool`. Uses conjunction as combination of elements.
    ///
    /// Use `Bool.andMonoid` to obtain an instance of this type.
extension Bool: Monoid {
    public static func empty() -> Bool {
        return true
    }
}
