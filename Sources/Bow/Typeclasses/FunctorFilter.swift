import Foundation

public protocol FunctorFilter: Functor {
    static func mapFilter<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> OptionOf<B>) -> Kind<Self, B>
}

public extension FunctorFilter {
    public static func flattenOption<A>(_ fa: Kind<Self, OptionOf<A>>) -> Kind<Self, A> {
        return mapFilter(fa, id)
    }
    
    public static func filter<A>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Bool) -> Kind<Self, A> {
        return mapFilter(fa, { a in f(a) ? Option.some(a) : Option.none() })
    }
}

// MARK: Syntax for FunctorFilter

public extension Kind where F: FunctorFilter {
    public func mapFilter<B>(_ f: @escaping (A) -> OptionOf<B>) -> Kind<F, B> {
        return F.mapFilter(self, f)
    }

    public static func flattenOption(_ fa: Kind<F, OptionOf<A>>) -> Kind<F, A> {
        return F.flattenOption(fa)
    }

    public func filter(_ f: @escaping (A) -> Bool) -> Kind<F, A> {
        return F.filter(self, f)
    }
}
