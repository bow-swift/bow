import Foundation

public protocol Bifunctor {
    associatedtype F
    
    func bimap<A, B, C, D>(_ fab : Kind2<F, A, B>, _ f1 : @escaping (A) -> C, _ f2 : @escaping (B) -> D) -> Kind2<F, C, D>
}

public extension Bifunctor {
    public func mapLeft<A, B, C>(_ fab : Kind2<F, A, B>, _ f : @escaping (A) -> C) -> Kind2<F, C, B> {
        return self.bimap(fab, f, id)
    }

    public func lift<A, B, C, D>(_ f1 : @escaping (A) -> C, _ f2 : @escaping (B) -> D) -> (Kind2<F, A, B>) -> Kind2<F, C, D> {
        return { fa in self.bimap(fa, f1, f2) }
    }
}
