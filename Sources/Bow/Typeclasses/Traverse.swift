import Foundation

public protocol Traverse : Functor, Foldable {
    func traverse<G, A, B, Appl>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, Kind<F, B>> where Appl : Applicative, Appl.F == G
}

public extension Traverse {
    public func map<A, B>(_ fa: Kind<F, A>, _ f: @escaping (A) -> B) -> Kind<F, B> {
        return (traverse(fa, { a in Id<B>.pure(f(a)) }, Id<B>.applicative()) as! Id<Kind<F, B>>).extract()
    }
    
    public func sequence<Appl, G, A>(_ applicative : Appl, _ fga : Kind<F, Kind<G, A>>) -> Kind<G, Kind<F, A>> where Appl : Applicative, Appl.F == G{
        return traverse(fga, id, applicative)
    }
    
    public func flatTraverse<Appl, Mon, G, A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Kind<G, Kind<F, B>>, _ applicative : Appl, _ monad : Mon) -> Kind<G, Kind<F, B>> where Appl : Applicative, Appl.F == G, Mon : Monad, Mon.F == F {
        return applicative.map(traverse(fa, f, applicative), monad.flatten)
    }
}
