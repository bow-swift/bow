import Foundation

public protocol Reducible : Foldable {
    func reduceLeftTo<A, B>(_ fa : Kind<F, A>, _ f : (A) -> B, _ g : (B, A) -> B) -> B
    func reduceRightTo<A, B>(_ fa : Kind<F, A>, _ f : (A) -> B, _ g : (A, Eval<B>) -> Eval<B>) -> Eval<B>
}

public extension Reducible {
    
    public func reduceLeft<A>(_ fa : Kind<F, A>, _ f : (A, A) -> A) -> A {
        return reduceLeftTo(fa, id, f)
    }
    
    public func reduceRight<A>(_ fa : Kind<F, A>, _ f : (A, Eval<A>) -> Eval<A>) -> Eval<A> {
        return reduceRightTo(fa, id, f)
    }
    
    public func reduceLeftToMaybe<A, B>(_ fa: Kind<F, A>, _ f: @escaping (A) -> B, _ g: @escaping (B, A) -> B) -> Maybe<B> {
        return Maybe<B>.some(reduceLeftTo(fa, f, g))
    }
    
    public func reduceRightToMaybe<A, B>(_ fa: Kind<F, A>, _ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<Maybe<B>> {
        return reduceRightTo(fa, f, g).map(Maybe<B>.some)
    }
    
    public func isEmpty<A>(_ fa: Kind<F, A>) -> Bool {
        return false
    }
    
    public func nonEmpty<A>(_ fa: Kind<F, A>) -> Bool {
        return true
    }
    
    public func reduce<A, SemiG>(_ fa : Kind<F, A>, _ semigroup : SemiG) -> A where SemiG : Semigroup, SemiG.A == A {
        return reduceLeft(fa, semigroup.combine)
    }
    
    public func reduceK<A, G, SemiGK>(_ fga : Kind<F, Kind<G, A>>, _ semigroupK : SemiGK) -> Kind<G, A> where SemiGK : SemigroupK, SemiGK.F == G {
        return reduce(fga, semigroupK.algebra())
    }
    
    public func reduceMap<A, B, SemiG>(_ fa : Kind<F, A>, _ f : (A) -> B, _ semigroup : SemiG) -> B where SemiG : Semigroup, SemiG.A == B {
        return reduceLeftTo(fa, f, { b, a in semigroup.combine(b, f(a)) })
    }
}




























