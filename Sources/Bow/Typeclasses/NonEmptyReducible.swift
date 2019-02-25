import Foundation

public protocol NonEmptyReducible: Reducible {
    associatedtype G: Foldable

    static func split<A>(_ fa: Kind<Self, A>) -> (A, Kind<G, A>)
}

public extension NonEmptyReducible {
    public static func foldLeft<A, B>(_ fa: Kind<Self, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        let (a, ga) = split(fa)
        return G.foldLeft(ga, f(b, a), f)
    }
    
    public static func foldRight<A, B>(_ fa: Kind<Self, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Eval.fix(Eval<(A, Kind<G, A>)>.always({ self.split(fa) }).flatMap { (a, ga) in f(a, G.foldRight(ga, b, f)) })
    }
    
    public static func reduceLeftTo<A, B>(_ fa: Kind<Self, A>, _ f: (A) -> B, _ g: @escaping (B, A) -> B) -> B {
        let (a, ga) = split(fa)
        return G.foldLeft(ga, f(a), { b, a in g(b, a) })
    }
    
    public static func reduceRightTo<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Eval.fix(Eval.always({ split(fa) }).flatMap { input -> Eval<B> in
            let (a, ga) = input
            let evalOpt = G.reduceRightToOption(ga, f, g)
            let res = evalOpt.flatMap { option in
                option.fold({ Eval.later({ f(a) })},
                            { b in g(a, Eval.now(b)) })
            }
            return Eval.fix(res)
        })
    }
    
    public static func fold<A: Monoid>(_ fa: Kind<Self, A>) -> A {
        let (a, ga) = split(fa)
        return a.combine(G.fold(ga))
    }
    
    public static func find<A>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Bool) -> Option<A> {
        let (a, ga) = split(fa)
        return f(a) ? Option.some(a) : G.find(ga, f)
    }
    
    public static func exists<A>(_ fa: Kind<Self, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        let (a, ga) = split(fa)
        return predicate(a) || G.exists(ga, predicate)
    }
    
    public static func forall<A>(_ fa: Kind<Self, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        let (a, ga) = split(fa)
        return predicate(a) && G.forall(ga, predicate)
    }
    
    public static func count<A: Monoid>(_ fa: Kind<Self, A>) -> Int64 {
        let (_, tail) = split(fa)
        return 1 + G.count(tail)
    }
    
    public static func get<A>(_ fa: Kind<Self, A>, _ index: Int64) -> Option<A> {
        if index == 0 {
            return Option.some(split(fa).0)
        } else {
            return G.get(split(fa).1, index - 1)
        }
    }
    
    public static func foldM<H: Monad, A, B>(_ fa: Kind<Self, A>, _ b: B, _ f: @escaping (B, A) -> Kind<H, B>) -> Kind<H, B> {
        let (a, ga) = split(fa)
        return H.flatMap(f(b, a), { bb in G.foldM(ga, bb, f)})
    }
}

// MARK Syntax for NonEmptyReducible {

public extension Kind where F: NonEmptyReducible {
    public func split() -> (A, Kind<F.G, A>) {
        return F.split(self)
    }
}
