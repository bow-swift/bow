import Foundation

public protocol Inject : Typeclass {
    associatedtype F
    associatedtype G
    associatedtype Function where Function : FunctionK, Function.F == F, Function.G == G
    
    func inj() -> Function
}

public extension Inject {
    public func invoke<A>(_ fa : Kind<F, A>) -> Kind<G, A> {
        return inj().invoke(fa)
    }
}
