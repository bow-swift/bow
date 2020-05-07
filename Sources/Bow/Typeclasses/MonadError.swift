import Foundation

/// A MonadError has the same capabilities as a `Monad` and an `ApplicativeError`.
public protocol MonadError: Monad, ApplicativeError {}

// MARK: Related functions

public extension MonadError {
    /// Checks if the value of a computation matches a predicate, raising an error if not.
    ///
    /// - Parameters:
    ///   - fa: A computation in the context implementing this instance.
    ///   - error: A function that produces an error of the type this instance is able to handle.
    ///   - predicate: A boolean predicate to test the value of the computation.
    /// - Returns: A value or an error in the context implementing this instance.
    static func ensure<A>(
        _ fa: Kind<Self, A>,
        _ error: @escaping () -> E,
        _ predicate: @escaping (A) -> Bool) -> Kind<Self, A> {
        flatMap(fa, { a in
            predicate(a) ? pure(a) : raiseError(error())
        })
    }
    
    /// Applies a monadic function to an effect discarding the output.
    ///
    /// - Parameters:
    ///   - fa: A computation.
    ///   - f: A monadic function which result will be discarded.
    /// - Returns: A computation with the effect of the initial computation.
    static func flatTapError<A, B>(
        _ fa: Kind<Self, A>,
        _ f: @escaping (E) -> Kind<Self, B>) -> Kind<Self, A> {
        handleErrorWith(fa) { e in
            f(e).handleErrorWith { _ in raiseError(e) }
                .followedBy(.raiseError(e))
        }
    }
}

// MARK: Syntax for MonadError

public extension Kind where F: MonadError {
    /// Checks if the value of this computation matches a predicate, raising an error if not.
    ///
    /// This is a convenience method to call `MonadError.ensure` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - error: A function that produces an error of the type this instance is able to handle.
    ///   - predicate: A boolean predicate to test the value of the computation.
    /// - Returns: A value or an error in the context implementing this instance.
    func ensure(
        _ error: @escaping () -> F.E,
        _ predicate: @escaping (A) -> Bool) -> Kind<F, A> {
        F.ensure(self, error, predicate)
    }
    
    /// Applies a monadic function to an effect discarding the output.
    ///
    /// - Parameters:
    ///   - f: A monadic function which result will be discarded.
    /// - Returns: A computation with the effect of the initial computation.
    func flatTapError<B>(_ f: @escaping (F.E) -> Kind<F, B>) -> Kind<F, A> {
        F.flatTapError(self, f)
    }
}
