import Foundation

public protocol TraverseFilter: Traverse, FunctorFilter {
    static func traverseFilter<A, B, G: Applicative>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, OptionOf<B>>) -> Kind<G, Kind<Self, B>>
}

public extension TraverseFilter {
    public static func filterA<A, G: Applicative>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, Bool>) -> Kind<G, Kind<Self, A>> {
        return traverseFilter(fa, { a in G.map(f(a), { b in b ? Option.some(a) : Option.none() }) })
    }
    
    public static func filter<A>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Bool) -> Kind<Self, A> {
        return (filterA(fa, { a in Id.pure(f(a)) })).extract()
    }
}

// MARK: Syntax for TraverseFilter

public extension Kind where F: TraverseFilter {
    public func traverseFilter<B, G: Applicative>(_ f: @escaping (A) -> Kind<G, OptionOf<B>>) -> Kind<G, Kind<F, B>> {
        return F.traverseFilter(self, f)
    }

    public func filterA<G: Applicative>(_ f: @escaping (A) -> Kind<G, Bool>) -> Kind<G, Kind<F, A>> {
        return F.filterA(self, f)
    }
}
