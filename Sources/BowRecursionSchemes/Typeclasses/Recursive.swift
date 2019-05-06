import Foundation
import Bow

public protocol Recursive {
    static func projectT<F: Functor>(_ tf: Kind<Self, F>) -> Kind<F, Kind<Self, F>>
}

public extension Recursive {
    static func project<F: Functor>() -> Coalgebra<F, Kind<Self, F>> {
        return { t in projectT(t) }
    }
    
    static func cata<F: Functor, A>(_ tf: Kind<Self, F>, _ algebra: @escaping Algebra<F, Eval<A>>) -> A {
        return F.hylo(algebra, project(), tf)
    }
}

// MARK: Syntax for Recursive

public extension Kind where F: Recursive, A: Functor {
    func projectT() -> Kind<A, Kind<F, A>> {
        return F.projectT(self)
    }

    static func project() -> Coalgebra<A, Kind<F, A>> {
        return F.project()
    }

    func cata<B>(_ algebra: @escaping Algebra<A, Eval<B>>) -> B  {
        return F.cata(self, algebra)
    }
}
