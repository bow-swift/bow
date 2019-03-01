import Foundation

open class FunctionK<F, G> {
    public init() {}

    open func invoke<A>(_ fa: Kind<F, A>) -> Kind<G, A> {
        fatalError("FunctionK.invoke must be implemented in subclasses")
    }

    public func andThen<H>(_ g: FunctionK<G, H>) -> FunctionK<F, H> {
        return ComposedFunctionK<F, G, H>(self, g)
    }

    public func compose<H>(_ g: FunctionK<H, F>) -> FunctionK<H, G> {
        return ComposedFunctionK<H, F, G>(g, self)
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

fileprivate class ComposedFunctionK<F, G, H>: FunctionK<F, H> {
    fileprivate let f: FunctionK<F, G>
    fileprivate let g: FunctionK<G, H>

    init(_ f: FunctionK<F, G>, _ g: FunctionK<G, H>) {
        self.f = f
        self.g = g
    }

    override func invoke<A>(_ fa: Kind<F, A>) -> Kind<H, A> {
        return g.invoke(f.invoke(fa))
    }
}
