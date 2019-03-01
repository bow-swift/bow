import Foundation

open class FunctionK<F, G> {
    public init() {}

    open func invoke<A>(_ fa: Kind<F, A>) -> Kind<G, A> {
        fatalError("FunctionK.invoke must be implemented in subclasses")
    }
}

public extension FunctionK where F == G {
    public static var id: FunctionK<F, F> {
        return IdFunctionK<F>()
    }
}

fileprivate class IdFunctionK<F>: FunctionK<F, F> {
    override func invoke<A>(_ fa: Kind<F, A>) -> Kind<F, A> {
        return fa
    }
}
