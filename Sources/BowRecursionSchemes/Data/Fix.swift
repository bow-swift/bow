import Foundation
import Bow

public final class ForFix {}
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
    public static func recursive() -> BirecursiveInstance {
        return BirecursiveInstance()
    }
    
    public static func corecursive() -> BirecursiveInstance {
        return BirecursiveInstance()
    }
    
    public static func birecursive() -> BirecursiveInstance {
        return BirecursiveInstance()
    }
    
    public class BirecursiveInstance : Birecursive {
        public typealias T = ForFix
        
        public func projectT<F, Func>(_ tf : Kind<ForFix, F>, _ functor : Func) -> Kind<F, Kind<ForFix, F>> where Func : Functor, Func.F == F {
            return functor.map(tf.fix().unFix, { x in x.value() })
        }
        
        public func embedT<Func, F>(_ tf : Kind<F, Eval<Kind<ForFix, F>>>, _ functor : Func) -> Eval<Kind<ForFix, F>> where Func : Functor, Func.F == F {
            return Eval.later { Fix<F>(unFix: tf) }
        }
    }
}
