import Foundation

public protocol MonadCombine : MonadFilter, Alternative {}

public extension MonadCombine {
    public func unite<G, A, Fold>(_ fga : Kind<F, Kind<G, A>>, _ foldable : Fold) -> Kind<F, A> where Fold : Foldable, Fold.F == G {
        return flatMap(fga, { ga in foldable.foldLeft(ga, self.empty(), { acc, a in self.combineK(acc, self.pure(a)) })})
    }
    
    public func separate<G, A, B, Bifold>(_ fgab : Kind<F, Kind2<G, A, B>>, _ bifoldable : Bifold) -> (Kind<F, A>, Kind<F, B>) where Bifold : Bifoldable, Bifold.F == G {
        let asep = flatMap(fgab, { gab in bifoldable.bifoldMap(gab, self.pure, constant(self.empty()), self.algebra()) })
        let bsep = flatMap(fgab, { gab in bifoldable.bifoldMap(gab, constant(self.empty()), self.pure, self.algebra()) } )
        return (asep, bsep)
    }
}
