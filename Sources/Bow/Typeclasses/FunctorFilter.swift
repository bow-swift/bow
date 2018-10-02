import Foundation

public protocol FunctorFilter : Functor {
    func mapFilter<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> OptionOf<B>) -> Kind<F, B>
}

public extension FunctorFilter {
    public func flattenOption<A>(_ fa : Kind<F, OptionOf<A>>) -> Kind<F, A> {
        return self.mapFilter(fa, id)
    }
    
    public func filter<A>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Bool) -> Kind<F, A> {
        return self.mapFilter(fa, { a in f(a) ? Option.some(a) : Option.none() })
    }
}
