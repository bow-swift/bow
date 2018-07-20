import Foundation

public class ForMu {}
public typealias MuOf<F> = Kind<ForMu, F>

open class Mu<F> : MuOf<F> {
    public static func fix(_ value : MuOf<F>) -> Mu<F> {
        return value as! Mu<F>
    }
    
    open func unMu<A>(_ fa : @escaping Algebra<F, Eval<A>>) -> Eval<A> {
        fatalError("unMu must be implemented in subclasses")
    }
}

public extension Kind where F == ForMu {
    public func fix() -> Mu<A> {
        return Mu<A>.fix(self)
    }
}

public extension Mu {
    public static func recursive() -> MuBirecursive {
        return MuBirecursive()
    }
    
    public static func corecursive() -> MuBirecursive {
        return MuBirecursive()
    }
    
    public static func birecursive() -> MuBirecursive {
        return MuBirecursive()
    }
}

public class MuBirecursive : Birecursive {
    public typealias T = ForMu
    
    public func projectT<F, Func>(_ tf: Kind<ForMu, F>, _ functor: Func) -> Kind<F, Kind<ForMu, F>> where F == Func.F, Func : Functor {
        return cata(tf, { ff in
            Eval.later { functor.map(ff, { f in
                self.embedT(functor.map(f.value(), { muf in
                    Eval.now(muf)
                }), functor).value()
            }) }
        }, functor)
    }
    
    public func embedT<Func, F>(_ tf: Kind<F, Eval<Kind<ForMu, F>>>, _ functor: Func) -> Eval<Kind<ForMu, F>> where Func : Functor, F == Func.F {
        return Eval.now(MuEmbed(tf, functor))
    }
}

fileprivate class MuEmbed<F, Func> : Mu<F> where Func : Functor, Func.F == F {
    private let tf : Kind<F, Eval<Kind<ForMu, F>>>
    private let functor : Func
    
    init(_ tf : Kind<F, Eval<Kind<ForMu, F>>>, _ functor : Func) {
        self.tf = tf
        self.functor = functor
    }
    
    override func unMu<A>(_ fa: @escaping Algebra<F, Eval<A>>) -> Eval<A> {
        return fa(functor.map(tf, { eval in eval.flatMap { x in x.fix().unMu(fa) } }))
    }
}
