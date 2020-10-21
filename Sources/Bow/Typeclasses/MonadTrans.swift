import Foundation

/// A monad transformer makes a new monad out of an existing monad, such that computations of the old monad may be embedded in the new one.
public protocol MonadTrans: Monad {
    /// The input type parameter of this transformer.
    associatedtype F: Monad

    /// Lift a computation from the F monad to the constructed monad.
    static func liftF<A>(_ fa: Kind<F, A>) -> Kind<Self, A>
}

extension Kind where F: MonadTrans {
    /// Lift a computation from the F monad to this monad.
    static func liftF(_ fa: Kind<F.F, A>) -> Kind<F, A> {
        F.liftF(fa)
    }
}
