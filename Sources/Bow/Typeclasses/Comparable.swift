import Foundation

public extension Comparable {
    static func sort(_ a: Self, _ b: Self) -> (Self, Self) {
        return a >= b ? (a, b) : (b, a)
    }

    static func max(_ a: Self, _ b: Self) -> Self {
        return a >= b ? a : b
    }

    static func min(_ a: Self, _ b: Self) -> Self {
        return a <= b ? a : b
    }
}
