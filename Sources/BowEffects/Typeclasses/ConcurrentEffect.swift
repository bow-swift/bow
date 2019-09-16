import Foundation
import Bow

/// Describes a function to cancel an effect
public typealias Disposable = () -> ()

/// ConcurrentEffect describes computations that can be cancelled and evaluated concurrently.
public protocol ConcurrentEffect: Effect {
    /// Evaluates a side-effectful computation, allowing its cancellation.
    ///
    /// - Parameters:
    ///   - fa: Computation.
    ///   - callback: Callback to process the result of the evaluation.
    /// - Returns: A computation describing the evaluation, providing a means to cancel it.
    static func runAsyncCancellable<A>(_ fa: Kind<Self, A>, _ callback: @escaping (Either<E, A>) -> Kind<Self, ()>) -> Kind<Self, Disposable>
}

// MARK: Syntax for ConcurrentEffect
public extension Kind where F: ConcurrentEffect {
    /// Evaluates a side-effectful computation, allowing its cancellation.
    ///
    /// - Parameter callback: Callback to process the result of the evaluation.
    /// - Returns: A computation describing the evaluation, providing a means to cancel it.
    func runAsyncCancellable(_ callback: @escaping (Either<F.E, A>) -> Kind<F, ()>) -> Kind<F, Disposable> {
        return F.runAsyncCancellable(self, callback)
    }
}
