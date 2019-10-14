import Foundation

/// Instance of `Semigroup` for `Bool`. Uses disjunction as combination of elements.
extension Bool: Semigroup {
    public func combine(_ other: Bool) -> Bool {
        return self || other
    }
}

/// Instance of `Monoid` for `Bool`. Uses disjunction as combination of elements and `false` as empty element.
extension Bool: Monoid {
    public static func empty() -> Bool {
        return false
    }
}

/// Instance of `Semiring` for `Bool`. Uses conjunction as multiplication of elements and `true` as empty element.
extension Bool: Semiring {
    public func multiply(_ other: Bool) -> Bool {
        return self && other
    }
    
    public static func one() -> Bool {
        return true
    }
}
