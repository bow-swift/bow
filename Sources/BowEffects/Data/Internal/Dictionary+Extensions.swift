import Foundation

func -<K: Hashable, V>(lhs: Dictionary<K, V>, rhs: K) -> Dictionary<K, V> {
    var copy = lhs
    copy.removeValue(forKey: rhs)
    return copy
}

func +<K: Hashable, V>(lhs: Dictionary<K, V>, rhs: (K, V)) -> Dictionary<K, V> {
    var copy = lhs
    copy[rhs.0] = rhs.1
    return copy
}

extension Dictionary {
    var arrayValues: [Value] {
        return Array(values)
    }
}
