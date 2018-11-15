import Foundation
import Bow

public protocol Corecursive {
    associatedtype T
    
    func embedT<Func, F>(_ tf : Kind<F, Eval<Kind<T, F>>>, _ functor : Func) -> Eval<Kind<T, F>> where Func : Functor, Func.F == F
}

public extension Corecursive {
    public func embed<Func, F>(_ functor : Func) -> Algebra<F, Eval<Kind<T, F>>> where Func : Functor, Func.F == F {
        return { x in self.embedT(x, functor) }
    }
    
    public func ana<Func, F, A>(_ a : A, _ coalgebra : @escaping Coalgebra<F, A>, _ functor : Func) -> Kind<T, F> where Func : Functor, Func.F == F {
        return functor.hylo(self.embed(functor), coalgebra, a)
    }
}
