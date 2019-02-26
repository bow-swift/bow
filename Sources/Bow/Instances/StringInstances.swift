import Foundation

/// Instance of `Semigroup` for `String`, using concatenation as combination method.
extension String: Semigroup {
    public func combine(_ other: String) -> String {
        return self + other
    }
}

/// Instance of `Monoid` for `String`, using concatenation as combination method and empty string as empty element.
extension String: Monoid {
    public static func empty() -> String {
        return ""
    }
}
