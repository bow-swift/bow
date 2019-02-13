import Foundation

extension Bool: Semigroup {
    public func combine(_ other: Bool) -> Bool {
        return self && other
    }
}

extension Bool: Monoid {
    public static func empty() -> Bool {
        return true
    }
}
