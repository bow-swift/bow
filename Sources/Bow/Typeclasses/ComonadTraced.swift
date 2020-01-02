public protocol ComonadTraced: Comonad {
    associatedtype W
    
    static func trace<M, A>(_ wa: Kind<Self, A>, _ m: M) -> A
}

public extension ComonadTraced {
    static func traces<M, A>(_ wa: Kind<Self, A>, _ f: @escaping (A) -> M) -> A {
        trace(wa, f(wa.extract()))
    }
}

// MARK: Syntax for ComonadTraced

public extension Kind where F: ComonadTraced {
    func trace<M>(_ m: M) -> A {
        F.trace(self, m)
    }
    
    func traces<M>(_ f: @escaping (A) -> M) -> A {
        F.traces(self, f)
    }
}
