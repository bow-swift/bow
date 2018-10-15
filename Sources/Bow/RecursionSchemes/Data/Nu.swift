import Foundation

public class ForNu {}
public typealias NuOf<F> = Kind<ForNu, F>

public class Nu<F> : NuOf<F> {
    public static func fix(_ value : NuOf<F>) -> Nu<F> {
        return value as! Nu<F>
    }
    
    public let a : Any
    public let unNu : Coalgebra<F, Any>
    
    public init<A>(_ a : A, _ unNu : @escaping Coalgebra<F, A>) {
        self.a = a
        self.unNu = unNu as! Coalgebra<F, Any>
    }
}

public extension Kind where F == ForNu {
    public func fix() -> Nu<A> {
        return Nu<A>.fix(self)
    }
}

public extension Nu {
    public static func recursive() -> NuBirecursive {
        return NuBirecursive()
    }
    
    public static func corecursive() -> NuBirecursive {
        return NuBirecursive()
    }
    
    public static func birecursive() -> NuBirecursive {
        return NuBirecursive()
    }
}

public class NuBirecursive : Birecursive {
    public typealias T = ForNu
    
    public func projectT<F, Func>(_ tf: Kind<ForNu, F>, _ functor: Func) -> Kind<F, Kind<ForNu, F>> where F == Func.F, Func : Functor {
        let fix = tf.fix()
        let unNu = fix.unNu
        return functor.map(unNu(fix.a), { x in Nu(x, unNu) })
    }
    
    public func embedT<Func, F>(_ tf: Kind<F, Eval<Kind<ForNu, F>>>, _ functor: Func) -> Eval<Kind<ForNu, F>> where Func : Functor, F == Func.F {
        return Eval.now(Nu(tf, { f in
            functor.map(f, { nu in
                functor.map(self.projectT(nu.value(), functor), Eval.now)
            })
        }))
    }
}
