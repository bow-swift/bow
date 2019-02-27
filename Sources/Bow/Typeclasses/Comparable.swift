import Foundation

public extension Comparable {
    /// Sorts two values.
    ///
    /// - Parameters:
    ///   - a: 1st value.
    ///   - b: 2nd value.
    /// - Returns: A tuple with the two values sorted.
    static func sort(_ a: Self, _ b: Self) -> (Self, Self) {
        return a >= b ? (a, b) : (b, a)
    }

    /// Gets the maximum of two values.
    ///
    /// - Parameters:
    ///   - a: 1st value.
    ///   - b: 2nd value.
    /// - Returns: Maximum of both values.
    static func max(_ a: Self, _ b: Self) -> Self {
        return a >= b ? a : b
    }

    /// Gets the minimum of two values.
    ///
    /// - Parameters:
    ///   - a: 1st value.
    ///   - b: 2nd value.
    /// - Returns: Minimum of both values.
    static func min(_ a: Self, _ b: Self) -> Self {
        return a <= b ? a : b
    }
}
