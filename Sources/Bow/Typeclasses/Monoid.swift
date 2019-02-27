import Foundation

/// A monoid is an algebraic structure that has the same properties as a semigroup, with an empty element.
public protocol Monoid: Semigroup {

    /// Empty element.
    ///
    /// The empty element must obey the monoid laws:
    ///
    ///     a.combine(empty()) == empty().combine(a) == a
    ///
    /// That is, combining any element with `empty` must return the original element.
    ///
    /// - Returns: A value of the implementing type satisfying the monoid laws.
    static func empty() -> Self
}
