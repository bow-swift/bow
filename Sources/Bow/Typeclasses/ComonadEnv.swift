public protocol ComonadEnv: Comonad {
    associatedtype E
    
    static func ask<A>(_ wa: Kind<Self, A>) -> E
}

public extension ComonadEnv {
    static func asks<A, EE>(_ wa: Kind<Self, A>, _ f: @escaping (E) -> EE) -> EE {
        f(ask(wa))
    }
}

// MARK: Syntax for ComonadEnv

public extension Kind where F: ComonadEnv {
    func ask() -> F.E {
        F.ask(self)
    }
    
    func asks<EE>(_ f: @escaping (F.E) -> EE) -> EE {
        F.asks(self, f)
    }
}
