import Foundation

// MARK: Instance of Semigroup for Bool. Uses disjunction as combination of elements.
extension Bool: Semigroup {
    public func combine(_ other: Bool) -> Bool {
        self || other
    }
}

// MARK: Instance of Monoid for Bool. Uses false as empty element.
extension Bool: Monoid {
    public static func empty() -> Bool {
        false
    }
}

// MARK: Instance of Semiring for Bool. Uses conjunction as multiplication of elements and true as unit element.
extension Bool: Semiring {
    public func multiply(_ other: Bool) -> Bool {
        self && other
    }
    
    public static func one() -> Bool {
        true
    }
}
