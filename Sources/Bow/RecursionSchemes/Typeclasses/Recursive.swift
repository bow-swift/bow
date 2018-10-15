import Foundation

public protocol Recursive {
    associatedtype T
    
    func projectT<F, Func>(_ tf : Kind<T, F>, _ functor : Func) -> Kind<F, Kind<T, F>> where Func : Functor, Func.F == F
}

public extension Recursive {
    public func project<F, Func>(_ functor : Func) -> Coalgebra<F, Kind<T, F>> where Func : Functor, Func.F == F {
        return { t in self.projectT(t, functor) }
    }
    
    public func cata<F, Func, A>(_ tf : Kind<T, F>, _ algebra : @escaping Algebra<F, Eval<A>>, _ functor : Func) -> A where Func : Functor, Func.F == F {
        return functor.hylo(algebra, self.project(functor), tf)
    }
}
