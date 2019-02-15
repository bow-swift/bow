import Foundation
import Bow

public protocol Corecursive {
    static func embedT<F: Functor>(_ tf: Kind<F, Eval<Kind<Self, F>>>) -> Eval<Kind<Self, F>>
}

public extension Corecursive {
    public static func embed<F: Functor>() -> Algebra<F, Eval<Kind<Self, F>>> {
        return { x in embedT(x) }
    }
    
    public static func ana<F: Functor, A>(_ a: A, _ coalgebra: @escaping Coalgebra<F, A>) -> Kind<Self, F> {
        return F.hylo(self.embed(), coalgebra, a)
    }
}

public extension Kind where F: Corecursive, A: Functor {
    public static func embedT(_ tf: Kind<A, Eval<Kind<F, A>>>) -> Eval<Kind<F, A>> {
        return F.embedT(tf)
    }

    public static func embed() -> Algebra<A, Eval<Kind<F, A>>> {
        return F.embed()
    }

    public static func ana<B>(_ a: B, _ coalgebra: @escaping Coalgebra<A, B>) -> Kind<F, A> {
        return F.ana(a, coalgebra)
    }
}
