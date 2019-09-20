import Foundation

/// A MonadWriter is a `Monad` with the ability to produce a stream of data in addition to the computed values.
public protocol MonadWriter: Monad {
    /// Type of the side stream of data produced by this monad
    associatedtype W
    
    /// Embeds a writer action.
    ///
    /// - Parameter aw: A tupe of the writer type and a value.
    /// - Returns: The writer action embedded in the context implementing this instance.
    static func writer<A>(_ aw: (W, A)) -> Kind<Self, A>

    /// Adds the side stream of data to the result of a computation.
    ///
    /// - Parameter fa: A computation.
    /// - Returns: The result of the computation paired with the side stream of data.
    static func listen<A>(_ fa: Kind<Self, A>) -> Kind<Self, (W, A)>

    /// Performs a computation and transforms the side stream of data.
    ///
    /// - Parameter fa: A computation that transform the stream of data.
    /// - Returns: Result of the computation.
    static func pass<A>(_ fa: Kind<Self, ((W) -> W, A)>) -> Kind<Self, A>
}

public extension MonadWriter {
    /// Produces a new value of the side stream of data.
    ///
    /// - Parameter w: New value.
    /// - Returns: Unit.
    static func tell(_ w: W) -> Kind<Self, ()> {
        return writer((w, ()))
    }
    
    /// Performs a computation and transforms the side stream of data, pairing it with the result of the computation.
    ///
    /// - Parameters:
    ///   - fa: A computation.
    ///   - f: A function to transform the side stream of data.
    /// - Returns: A tuple of the transformation of the side stream and the result of the computation.
    static func listens<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (W) -> B) -> Kind<Self, (B, A)> {
        return map(listen(fa), { pair in (f(pair.0), pair.1) })
    }
    
    /// Transforms the side stream of data of a given computation.
    ///
    /// - Parameters:
    ///   - fa: A computation.
    ///   - f: Transforming function.
    /// - Returns: A computation with the same result as the provided one, with the transformed side stream of data.
    static func censor<A>(_ fa: Kind<Self, A>, _ f: @escaping (W) -> W) -> Kind<Self, A> {
        return pass(fa.map { a in (f, a) })
    }
}

// MARK: Syntax for MonadWriter

public extension Kind where F: MonadWriter {
    /// Embeds a writer action.
    ///
    /// This is a convenience method to call `MonadWriter.writer` as a static method of this type.
    ///
    /// - Parameter aw: A tupe of the writer type and a value.
    /// - Returns: The writer action embedded in the context implementing this instance.
    static func writer(_ aw: (F.W, A)) -> Kind<F, A> {
        return F.writer(aw)
    }

    /// Adds the side stream of data to the result of this computation.
    ///
    /// This is a convenience method to call `MonadWriter.listen` as an instance method of this type.
    ///
    /// - Returns: The result of the computation paired with the side stream of data.
    func listen() -> Kind<F, (F.W, A)> {
        return F.listen(self)
    }

    /// Performs a computation and transforms the side stream of data.
    ///
    /// This is a convenience method to call `MonadWriter.pass` as a static method of this type.
    ///
    /// - Parameter fa: A computation that transform the stream of data.
    /// - Returns: Result of the computation.
    static func pass(_ fa: Kind<F, ((F.W) -> F.W, A)>) -> Kind<F, A> {
        return F.pass(fa)
    }

    /// Produces a new value of the side stream of data.
    ///
    /// This is a convenience method to call `MonadWriter.tell` as a static method of this type.
    ///
    /// - Parameter w: New value.
    /// - Returns: Unit.
    static func tell(_ w: F.W) -> Kind<F, ()> {
        return F.tell(w)
    }

    /// Performs this computation and transforms the side stream of data, pairing it with the result of this computation.
    ///
    /// This is a convenience method to call `MonadWriter.listens` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - f: A function to transform the side stream of data.
    /// - Returns: A tuple of the transformation of the side stream and the result of the computation.
    func listens<B>(_ f: @escaping (F.W) -> B) -> Kind<F, (B, A)> {
        return F.listens(self, f)
    }

    /// Transforms the side stream of data of this computation.
    ///
    /// This is a convenience method to call `MonadWriter.censor` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - f: Transforming function.
    /// - Returns: A computation with the same result as the provided one, with the transformed side stream of data.
    func censor(_ f: @escaping (F.W) -> F.W) -> Kind<F, A> {
        return F.censor(self, f)
    }
}
