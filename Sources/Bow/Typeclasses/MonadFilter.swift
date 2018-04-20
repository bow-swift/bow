import Foundation

public protocol MonadFilter : Monad, FunctorFilter {
    func empty<A>() -> Kind<F, A>
}

public extension MonadFilter {
    public func mapFilter<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Maybe<B>) -> Kind<F, B>{
        return flatMap(fa, { a in
            f(a).fold(self.empty, self.pure)
        })
    }
}
