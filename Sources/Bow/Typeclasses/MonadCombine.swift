import Foundation

/// A MonadCombine has the capabilities of `MonadFilter` and `Alternative` together.
public protocol MonadCombine: MonadFilter, Alternative {}

public extension MonadCombine {
    /// Fold over the inner structure to combine all of the values with our combine method inherited from `MonoidK.
    ///
    /// - Parameter fga: Nested contexts value.
    /// - Returns: A value in the context implementing this instance where the inner context has been folded.
    static func unite<G: Foldable, A>(_ fga: Kind<Self, Kind<G, A>>) -> Kind<Self, A> {
        return flatMap(fga, { ga in G.foldLeft(ga, empty(), { acc, a in combineK(acc, pure(a)) })})
    }
}

// MARK: Syntax for MonadCombine

public extension Kind where F: MonadCombine {
    /// Fold over the inner structure to combine all of the values with our combine method inherited from `MonoidK.
    ///
    /// This is a convenience method to call `MonadCombine.unite` as a static method of this type.
    ///
    /// - Parameter fga: Nested contexts value.
    /// - Returns: A value in the context implementing this instance where the inner context has been folded.
    static func unite<G: Foldable>(_ fga: Kind<F, Kind<G, A>>) -> Kind<F, A> {
        return F.unite(fga)
    }
}
