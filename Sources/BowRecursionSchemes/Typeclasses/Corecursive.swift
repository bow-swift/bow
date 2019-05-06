import Foundation
import Bow

public protocol Corecursive {
    static func embedT<F: Functor>(_ tf: Kind<F, Eval<Kind<Self, F>>>) -> Eval<Kind<Self, F>>
}

public extension Corecursive {
    static func embed<F: Functor>() -> Algebra<F, Eval<Kind<Self, F>>> {
        return { x in embedT(x) }
    }

    static func ana<F: Functor, A>(_ a: A, _ coalgebra: @escaping Coalgebra<F, A>) -> Kind<Self, F> {
        return F.hylo(self.embed(), coalgebra, a)
    }
}

// MARK: Syntax for Corecursive

public extension Kind where F: Corecursive, A: Functor {
    static func embedT(_ tf: Kind<A, Eval<Kind<F, A>>>) -> Eval<Kind<F, A>> {
        return F.embedT(tf)
    }

    static func embed() -> Algebra<A, Eval<Kind<F, A>>> {
        return F.embed()
    }

    static func ana<B>(_ a: B, _ coalgebra: @escaping Coalgebra<A, B>) -> Kind<F, A> {
        return F.ana(a, coalgebra)
    }
}
