public protocol ComonadTraced: Comonad {
    associatedtype M
    
    static func trace<A>(_ wa: Kind<Self, A>, _ m: M) -> A
}

public extension ComonadTraced {
    static func traces<A>(_ wa: Kind<Self, A>, _ f: @escaping (A) -> M) -> A {
        trace(wa, f(wa.extract()))
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
}
