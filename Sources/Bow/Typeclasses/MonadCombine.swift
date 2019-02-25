import Foundation

public protocol MonadCombine: MonadFilter, Alternative {}

public extension MonadCombine {
    public static func unite<G: Foldable, A>(_ fga: Kind<Self, Kind<G, A>>) -> Kind<Self, A> {
        return flatMap(fga, { ga in G.foldLeft(ga, empty(), { acc, a in combineK(acc, pure(a)) })})
    }
}

// MARK: Syntax for MonadCombine

public extension Kind where F: MonadCombine {
    public static func unite<G: Foldable, A>(_ fga: Kind<F, Kind<G, A>>) -> Kind<F, A> {
        return F.unite(fga)
    }
}
