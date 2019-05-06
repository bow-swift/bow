import Foundation

/// Witness for the `SetK<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForSetK {}

/// Higher Kinded Type alias to improve readability over `Kind<ForSetK, A>`.
public typealias SetKOf<A> = Kind<ForSetK, A>

/// An unordered collection of unique elements, wrapped to act as a Higher Kinded Type.
public final class SetK<A: Hashable>: SetKOf<A> {
    fileprivate let set: Set<A>

    /// Union of two sets.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the union.
    ///   - rhs: Right hand side of the union.
    /// - Returns: A new set that includes all elements present in both sets.
    public static func +(lhs: SetK<A>, rhs: SetK<A>) -> SetK<A> {
        return SetK(lhs.set.union(rhs.set))
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to SetK.
    public static func fix(_ fa: SetKOf<A>) -> SetK<A> {
        return fa as! SetK<A>
    }

    /// Initializes a `SetK` with the elements of a `Swift.Set`.
    ///
    /// - Parameter set: A set of elements to be wrapped in this `SetK`.
    public init(_ set: Set<A>) {
        self.set = set
    }

    /// Initializes a `SetK` from a variable number of elements.
    ///
    /// - Parameter elements: Values to be wrapped in this `SetK`.
    public init(_ elements: A...) {
        self.set = Set(elements)
    }

    /// Extracts a `Swift.Set` from this wrapper.
    public var asSet: Set<A> {
        return set
    }

    /// Combines this set with another using the union of the underlying `Swift.Set`s.
    ///
    /// - Parameter y: A set
    /// - Returns: A set containing the elements of the two sets.
    public func combineK(_ y: SetK<A>) -> SetK<A> {
        return self + y
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to SetK.
public postfix func ^<A>(_ fa: SetKOf<A>) -> SetK<A> {
    return SetK.fix(fa)
}

// MARK: Instance of `Semigroup` for `SetK`
extension SetK: Semigroup {
    public func combine(_ other: SetK<A>) -> SetK<A> {
        return self + other
    }
}

// MARK: Instance of `Monoid` for `SetK`
extension SetK: Monoid {
    public static func empty() -> SetK<A> {
        return SetK(Set([]))
    }
}

// MARK: Set extensions
public extension Set {
    /// Wraps this set into a `SetK`.
    ///
    /// - Returns: A `SetK` that contains the elements of this set.
    func k() -> SetK<Element> {
        return SetK(self)
    }
}
