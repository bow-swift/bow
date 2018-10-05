import Foundation

public protocol Profunctor {
    associatedtype F
    
    func dimap<A, B, C, D>(_ fab : Kind2<F, A, B>, _ f : @escaping (C) -> A, _ g : @escaping (B) -> D) -> Kind2<F, C, D>
}

public extension Profunctor {
    public func lmap<A, B, C>(_ fab : Kind2<F, A, B>, _ f : @escaping (C) -> A) -> Kind2<F, C, B> {
        return self.dimap(fab, f, id)
    }
    
    public func rmap<A, B, D>(_ fab : Kind2<F, A, B>, _ f : @escaping (B) -> D) -> Kind2<F, A, D> {
        return self.dimap(fab, id, f)
    }
}
