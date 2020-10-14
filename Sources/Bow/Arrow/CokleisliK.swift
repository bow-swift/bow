import Foundation

/// CokleisliK represents a function with the signature `(Kind<F, A>) -> B`
/// that is polymorphic on A, where F and B are fixed.
/// Subclasses of `CokleisliK` need to implement `invoke`.
open class CokleisliK<F, B> {
    /// Initializer
    public init() {}

    /// Invokes this transformation.
    ///
    /// - Parameter fa: Input to this function
    /// - Returns: Transformed input.
    open func invoke<A>(_ fa: Kind<F, A>) -> B {
        fatalError("CokleisliK.invoke must be implemented in subclasses")
    }

    /// Invokes this transformation.
    ///
    /// - Parameter fa: Input to this function
    /// - Returns: Transformed input.
    public func callAsFunction<A>(_ fa: Kind<F, A>) -> B {
        invoke(fa)
    }

    /// Composes this function with another one.
    ///
    /// - Parameter g: Function to compose with this one.
    /// - Returns: A function that transform the input with this function and the received one afterwards.
    public func andThen<H>(_ g: Function1<B, H>) -> CokleisliK<F, H> {
        Composed<F, B, H>(self, g)
    }

    /// Composes this function with another one.
    ///
    /// - Parameter g: Function to compose with this one.
    /// - Returns: A function that transform the input with this function and the received one afterwards.
    public func andThen<H>(_ g: @escaping (B) -> H) -> CokleisliK<F, H> {
        andThen(Function1(g))
    }

    /// Composes this function with another one.
    ///
    /// - Parameter g: Function to compose with this one.
    /// - Returns: A function that transform the input with the received function and this one afterwards.
    public func compose<H>(_ g: Function1<B, H>) -> CokleisliK<F, H> {
        andThen(g)
    }

    /// Composes this function with another one.
    ///
    /// - Parameter g: Function to compose with this one.
    /// - Returns: A function that transform the input with the received function and this one afterwards.
    public func compose<H>(_ g: @escaping (B) -> H) -> CokleisliK<F, H> {
        andThen(g)
    }

    private class Composed<F, T, B>: CokleisliK<F, B> {
        private let f: CokleisliK<F, T>
        private let g: Function1<T, B>

        init(_ f: CokleisliK<F, T>, _ g: Function1<T, B>) {
            self.f = f
            self.g = g
        }

        override func invoke<A>(_ fa: Kind<F, A>) -> B {
            g(f(fa))
        }
    }
}
