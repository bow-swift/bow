import Foundation

public protocol MonadCombine: MonadFilter, Alternative {}

public extension MonadCombine {
    public static func unite<G: Foldable, A>(_ fga: Kind<Self, Kind<G, A>>) -> Kind<Self, A> {
        return flatMap(fga, { ga in G.foldLeft(ga, empty(), { acc, a in combineK(acc, pure(a)) })})
    }
    
//    public func separate<G, A, B, Bifold>(_ fgab : Kind<Self, Kind2<G, A, B>>, _ bifoldable : Bifold) -> (Kind<Self, A>, Kind<Self, B>) where Bifold : Bifoldable, Bifold.F == G {
//        let asep = flatMap(fgab, { gab in bifoldable.bifoldMap(gab, self.pure, constant(self.empty()), self.algebra()) })
//        let bsep = flatMap(fgab, { gab in bifoldable.bifoldMap(gab, constant(self.empty()), self.pure, self.algebra()) } )
//        return (asep, bsep)
//    }
}

// MARK: Syntax for MonadCombine

public extension Kind where F: MonadCombine {
    public static func unite<G: Foldable, A>(_ fga: Kind<F, Kind<G, A>>) -> Kind<F, A> {
        return F.unite(fga)
    }
}
