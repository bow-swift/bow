import Foundation

// MARK: Instance of `Semigroup` for `Set`
extension Set: Semigroup {
    public func combine(_ other: Set<Element>) -> Set<Element> {
        self.union(other)
    }
}

// MARK: Instance of `Monoid` for `Set`
extension Set: Monoid {
    public static func empty() -> Set<Element> {
        Set()
    }
}
