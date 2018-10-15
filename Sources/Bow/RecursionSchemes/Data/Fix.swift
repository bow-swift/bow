import Foundation

public class ForFix {}
public typealias FixOf<A> = Kind<ForFix, A>

public class Fix<A> : FixOf<A> {
    public let unFix : Kind<A, Eval<FixOf<A>>>
    
    public static func fix(_ value : FixOf<A>) -> Fix<A> {
        return value as! Fix<A>
    }
    
    public init(unFix : Kind<A, Eval<FixOf<A>>>) {
        self.unFix = unFix
    }
}

public extension Kind where F == ForFix {
    public func fix() -> Fix<A> {
        return Fix<A>.fix(self)
    }
}

public extension Fix {
    public static func recursive() -> FixBirecursive {
        return FixBirecursive()
    }
    
    public static func corecursive() -> FixBirecursive {
        return FixBirecursive()
    }
    
    public static func birecursive() -> FixBirecursive {
        return FixBirecursive()
    }
}

public class FixBirecursive : Birecursive {
    public typealias T = ForFix
    
    public func projectT<F, Func>(_ tf : Kind<ForFix, F>, _ functor : Func) -> Kind<F, Kind<ForFix, F>> where Func : Functor, Func.F == F {
        return functor.map(tf.fix().unFix, { x in x.value() })
    }
    
    public func embedT<Func, F>(_ tf : Kind<F, Eval<Kind<ForFix, F>>>, _ functor : Func) -> Eval<Kind<ForFix, F>> where Func : Functor, Func.F == F {
        return Eval.later { Fix(unFix: tf) }
    }
}
