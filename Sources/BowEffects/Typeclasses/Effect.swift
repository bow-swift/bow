import Foundation
import Bow

/// Effect is a Monad that can suspend side effects into the context implementing it and supports lazy and potentially asynchronous evaluation.
public protocol Effect: Async {
    /// Evaluates a side-effectful computation.
    ///
    /// - Parameters:
    ///   - fa: Computation to be evaluated.
    ///   - callback: Callback to process the result of the computation.
    /// - Returns: A computation describing the evaluation.
    static func runAsync<A>(_ fa: Kind<Self, A>, _ callback: @escaping (Either<E, A>) -> Kind<Self, ()>) -> Kind<Self, ()>
}

// MARK: Syntax for Effect
public extension Kind where F: Effect {
    /// Evaluates a side-effectful computation.
    ///
    /// - Parameter callback: Callback to process the result of the computation.
    /// - Returns: A computation describing the evaluation.
    func runAsync(_ callback: @escaping (Either<F.E, A>) -> Kind<F, ()>) -> Kind<F, ()> {
        return F.runAsync(self, callback)
    }
}
