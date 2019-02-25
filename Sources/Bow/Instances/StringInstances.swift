import Foundation

    /// Instance of `Semigroup` for `String`, using concatenation as combination method.
    ///
    /// Use `String.concatSemigroup` to obtain an instance of this type.
extension String: Semigroup {
    public func combine(_ other: String) -> String {
        return self + other
    }
}

    /// Instance of `Monoid` for `String`, using concatenation as combination method.
    ///
    /// Use `String.concatMonoid` to obtain an instance of this type.
extension String: Monoid {
    public static func empty() -> String {
        return ""
    }
}
