import Foundation

public protocol NonEmptyReducible : Reducible {
    associatedtype G
    associatedtype Fold where Fold : Foldable, Fold.F == G
    
    func foldable() -> Fold
    func split<A>(_ fa : Kind<F, A>) -> (A, Kind<G, A>)
}

public extension NonEmptyReducible {
    public func foldLeft<A, B>(_ fa: Kind<F, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        let (a, ga) = split(fa)
        return foldable().foldLeft(ga, f(b, a), f)
    }
    
    public func foldRight<A, B>(_ fa: Kind<F, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Eval<(A, Kind<G, A>)>.always({ self.split(fa) }).flatMap{ (a, ga) in f(a, self.foldable().foldRight(ga, b, f)) }
    }
    
    public func reduceLeftTo<A, B>(_ fa: Kind<F, A>, _ f: (A) -> B, _ g: @escaping (B, A) -> B) -> B {
        let (a, ga) = split(fa)
        return foldable().foldLeft(ga, f(a), { b, a in g(b, a) })
    }
    
    public func reduceRightTo<A, B>(_ fa: Kind<F, A>, _ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Eval.always({ self.split(fa) }).flatMap{ (input) in
            let (a, ga) = input
            return self.foldable().reduceRightToOption(ga, f, g).flatMap { option in
                option.fold({ Eval.later({ f(a) })},
                            { b in g(a, Eval.now(b)) })
            }
        }
    }
    
    public func fold<A, Mono>(_ monoid : Mono, _ fa : Kind<F, A>) -> A where Mono : Monoid, Mono.A == A {
        let (a, ga) = split(fa)
        return monoid.combine(a, foldable().fold(monoid, ga))
    }
    
    public func find<A>(_ fa: Kind<F, A>, _ f: @escaping (A) -> Bool) -> Option<A> {
        let (a, ga) = split(fa)
        return f(a) ? Option.some(a) : foldable().find(ga, f)
    }
    
    public func exists<A>(_ fa: Kind<F, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        let (a, ga) = split(fa)
        return predicate(a) || foldable().exists(ga, predicate)
    }
    
    public func forall<A>(_ fa: Kind<F, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        let (a, ga) = split(fa)
        return predicate(a) && foldable().forall(ga, predicate)
    }
    
    public func size<A, Mono>(_ monoid: Mono, _ fa: Kind<F, A>) -> Int64 where Mono : Monoid, Mono.A == Int64 {
        let (_, tail) = split(fa)
        return 1 + foldable().size(monoid, tail)
    }
    
    public func get<A>(_ fa: Kind<F, A>, _ index: Int64) -> Option<A> {
        if index == 0 {
            return Option.some(split(fa).0)
        } else {
            return foldable().get(split(fa).1, index - 1)
        }
    }
    
    public func foldM<G, A, B, Mon>(_ fa: Kind<F, A>, _ b: B, _ f: @escaping (B, A) -> Kind<G, B>, _ monad: Mon) -> Kind<G, B> where G == Mon.F, Mon : Monad {
        let (a, ga) = split(fa)
        return monad.flatMap(f(b, a), { bb in self.foldable().foldM(ga, bb, f, monad)})
    }
}
