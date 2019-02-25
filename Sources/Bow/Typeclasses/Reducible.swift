import Foundation

public protocol Reducible: Foldable {
    static func reduceLeftTo<A, B>(_ fa : Kind<Self, A>, _ f : (A) -> B, _ g : (B, A) -> B) -> B
    static func reduceRightTo<A, B>(_ fa : Kind<Self, A>, _ f : (A) -> B, _ g : (A, Eval<B>) -> Eval<B>) -> Eval<B>
}

public extension Reducible {
    public static func reduceLeft<A>(_ fa : Kind<Self, A>, _ f : (A, A) -> A) -> A {
        return reduceLeftTo(fa, id, f)
    }
    
    public static func reduceRight<A>(_ fa : Kind<Self, A>, _ f : (A, Eval<A>) -> Eval<A>) -> Eval<A> {
        return reduceRightTo(fa, id, f)
    }
    
    public static func reduceLeftToOption<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (B, A) -> B) -> Option<B> {
        return Option<B>.some(reduceLeftTo(fa, f, g))
    }
    
    public static func reduceRightToOption<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<Option<B>> {
        return Eval<Option<B>>.fix(reduceRightTo(fa, f, g).map(Option<B>.some))
    }
    
    public static func isEmpty<A>(_ fa: Kind<Self, A>) -> Bool {
        return false
    }
    
    public static func nonEmpty<A>(_ fa: Kind<Self, A>) -> Bool {
        return true
    }
    
    public static func reduce<A: Semigroup>(_ fa : Kind<Self, A>) -> A {
        return reduceLeft(fa, { b, a in a.combine(b) })
    }
    
//    public static func reduceK<A, G: SemigroupK>(_ fga : Kind<Self, Kind<G, A>>) -> Kind<G, A> {
//        return reduce(fga, G.algebra())
//    }
    
    public static func reduceMap<A, B: Semigroup>(_ fa : Kind<Self, A>, _ f : (A) -> B) -> B {
        return reduceLeftTo(fa, f, { b, a in b.combine(f(a)) })
    }
}

// MARK: Syntax for Reducible

public extension Kind where F: Reducible {
    public func reduceLeftTo<B>(_ f : (A) -> B, _ g : (B, A) -> B) -> B {
        return F.reduceLeftTo(self, f, g)
    }

    public func reduceRightTo<B>(_ f : (A) -> B, _ g : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return F.reduceRightTo(self, f, g)
    }

    public func reduceMap<B: Semigroup>(_ f : (A) -> B) -> B {
        return F.reduceMap(self, f)
    }
}

public extension Kind where F: Reducible, A: Semigroup {
    public func reduce() -> A {
        return F.reduce(self)
    }
}
