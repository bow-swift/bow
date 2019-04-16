import Foundation

/// A transformation between two kinds.
///
/// As `Function1<A, B>` represents a transformation from `A` to `B`, `FunctionK<F, G>` represents a transformation from `Kind<F, A>` to `Kind<G, A>`. Subclasses of `FunctionK` need to implement `invoke`.
open class FunctionK<F, G> {
    /// Initializer
    public init() {}

    /// Invokes this transformation.
    ///
    /// - Parameter fa: Input to this function
    /// - Returns: Transformed input.
    open func invoke<A>(_ fa: Kind<F, A>) -> Kind<G, A> {
        fatalError("FunctionK.invoke must be implemented in subclasses")
    }

    /// Composes this function with another one.
    ///
    /// - Parameter g: Function to compose with this one.
    /// - Returns: A function that transform the input with this function and the received one afterwards.
    public func andThen<H>(_ g: FunctionK<G, H>) -> FunctionK<F, H> {
        return ComposedFunctionK<F, G, H>(self, g)
    }

    /// Composes this function with another one.
    ///
    /// - Parameter g: Function to compose with this one.
    /// - Returns: A function that transform the input with the received function and this one afterwards.
    public func compose<H>(_ g: FunctionK<H, F>) -> FunctionK<H, G> {
        return ComposedFunctionK<H, F, G>(g, self)
    }
}

// MARK: Identity FunctionK

public extension FunctionK where F == G {
    /// Identity `FunctionK`.
    ///
    /// It returns the input unmodified.
    static var id: FunctionK<F, F> {
        return IdFunctionK<F>()
    }
}

// MARK: Identity and Composed FunctionK

private class IdFunctionK<F>: FunctionK<F, F> {
    override func invoke<A>(_ fa: Kind<F, A>) -> Kind<F, A> {
        return fa
    }
}

private class ComposedFunctionK<F, G, H>: FunctionK<F, H> {
    private let f: FunctionK<F, G>
    private let g: FunctionK<G, H>

    init(_ f: FunctionK<F, G>, _ g: FunctionK<G, H>) {
        self.f = f
        self.g = g
    }

    override func invoke<A>(_ fa: Kind<F, A>) -> Kind<H, A> {
        return g.invoke(f.invoke(fa))
    }
}
