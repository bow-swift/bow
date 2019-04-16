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
    static func ensure<A>(_ fa: Kind<Self, A>, _ error: @escaping () -> E, _ predicate: @escaping (A) -> Bool) -> Kind<Self, A> {
        return flatMap(fa, { a in
            predicate(a) ? pure(a) : raiseError(error())
        })
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
    func ensure(_ error: @escaping () -> F.E, _ predicate: @escaping (A) -> Bool) -> Kind<F, A> {
        return F.ensure(self, error, predicate)
    }
}
