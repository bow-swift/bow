import Foundation

// MARK: Instance of `Semigroup` for `Dictionary`

extension Dictionary: Semigroup {
    public func combine(_ other: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var copy = self
        other.forEach { key, value in
            copy[key] = value
        }
        return copy
    }
}

// MARK: Instances of `Monoid` for `Dictionary`

extension Dictionary: Monoid {
    public static func empty() -> Dictionary<Key, Value> {
        [:]
    }
}
