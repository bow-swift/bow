import Foundation

/// Instance of `Semigroup` for `Bool`. Uses conjunction as combination of elements.
extension Bool: Semigroup {
    public func combine(_ other: Bool) -> Bool {
        return self && other
    }
}

/// Instance of `Monoid` for `Bool`. Uses conjunction as combination of elements and `true` as empty element.
extension Bool: Monoid {
    public static func empty() -> Bool {
        return true
    }
}
