public protocol ComonadStore: Comonad {
    associatedtype S
    
    static func position<A>(_ wa: Kind<Self, A>) -> S
    static func peek<A>(_ wa: Kind<Self, A>, _ s: S) -> A
    static func peeks<A>(_ wa: Kind<Self, A>, _ f: @escaping (S) -> S) -> A
    static func seek<A>(_ wa: Kind<Self, A>, _ s: S) -> Kind<Self, A>
    static func seeks<A>(_ wa: Kind<Self, A>, _ f: @escaping (S) -> S) -> Kind<Self, A>
    static func experiment<F: Functor, A>(_ wa: Kind<Self, A>, _ f: @escaping (S) -> Kind<F, S>) -> Kind<F, A>
}

// MARK: Syntax for ComonadStore

public extension Kind where F: ComonadStore {
    var position: F.S {
        F.position(self)
    }
    
    func peek(_ s: F.S) -> A {
        F.peek(self, s)
    }
    
    func peeks(_ f: @escaping (F.S) -> F.S) -> A {
        F.peeks(self, f)
    }
    
    func seek(_ s: F.S) -> Kind<F, A> {
        F.seek(self, s)
    }
    
    func seeks(_ f: @escaping (F.S) -> F.S) -> Kind<F, A> {
        F.seeks(self, f)
    }
    
    func experiment<G: Functor>(_ f: @escaping (F.S) -> Kind<G, F.S>) -> Kind<G, A> {
        F.experiment(self, f)
    }
}
