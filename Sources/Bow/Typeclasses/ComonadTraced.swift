public protocol ComonadTraced: Comonad {
    associatedtype M
    
    static func trace<A>(_ wa: Kind<Self, A>, _ m: M) -> A
    static func listens<A, B>(_ wa: Kind<Self, A>, _ f: @escaping (M) -> B) -> Kind<Self, (B, A)>
    static func censor<A>(_ wa: Kind<Self, A>, _ f: @escaping (M) -> M) -> Kind<Self, A>
    static func pass<A>(_ wa: Kind<Self, A>) -> Kind<Self, ((M) -> M) -> A>
}

public extension ComonadTraced {
    static func traces<A>(_ wa: Kind<Self, A>, _ f: @escaping (A) -> M) -> A {
        trace(wa, f(wa.extract()))
    }
    
    static func listen<A>(_ wa: Kind<Self, A>) -> Kind<Self, (M, A)> {
        listens(wa, id)
    }
}

// MARK: Syntax for ComonadTraced

public extension Kind where F: ComonadTraced {
    func trace(_ m: F.M) -> A {
        F.trace(self, m)
    }
    
    func traces(_ f: @escaping (A) -> F.M) -> A {
        F.traces(self, f)
    }
    
    func listens<B>(_ f: @escaping (F.M) -> B) -> Kind<F, (B, A)> {
        F.listens(self, f)
    }
    
    func listen() -> Kind<F, (F.M, A)> {
        F.listen(self)
    }
    
    func censor(_ f: @escaping (F.M) -> F.M) -> Kind<F, A> {
        F.censor(self, f)
    }
    
    func pass() -> Kind<F, ((F.M) -> F.M) -> A>  {
        F.pass(self)
    }
}
