import Bow
import Foundation

/// UsafeRun provides capabilities to run a computation unsafely, synchronous or asynchronously.
public protocol UnsafeRun: MonadError {
    /// Unsafely runs a computation in a synchronous manner.
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue used to run the computation.
    ///   - fa: Computation to be run.
    /// - Returns: Result of running the computation.
    /// - Throws: Error happened during the execution of the computation, of the error type of the underlying `MonadError`.
    static func runBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<Self, A>) throws -> A
    
    /// Unsafely runs a computation in an asynchronous manner.
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue used to run the computation.
    ///   - fa: Computation to be run.
    ///   - callback: Callback to report the result of the evaluation.
    static func runNonBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<Self, A>, _ callback: @escaping Callback<E, A>)
}

// MARK: Syntax for UnsafeRun

public extension Kind where F: UnsafeRun {
    /// Unsafely runs a computation in a synchronous manner.
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue used to run the computation. Defaults to the main queue.
    ///   - fa: Computation to be run.
    /// - Returns: Result of running the computation.
    /// - Throws: Error happened during the execution of the computation, of the error type of the underlying `MonadError`.
    static func runBlocking(on queue: DispatchQueue = .main, _ fa: @escaping () -> Kind<F, A>) throws -> A {
        return try F.runBlocking(on: queue, fa)
    }

    /// Unsafely runs a computation in an asynchronous manner.
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue used to run the computation. Defaults to the main queue.
    ///   - fa: Computation to be run.
    ///   - callback: Callback to report the result of the evaluation.
    static func runNonBlocking(on queue: DispatchQueue = .main, _ fa: @escaping () -> Kind<F, A>, _ callback: @escaping Callback<F.E, A>) {
        return F.runNonBlocking(on: queue, fa, callback)
    }
}

// MARK: Syntax for DispatchQueue and UnsafeRun

public extension DispatchQueue {
    /// Unsafely runs a computation in a synchronous manner.
    ///
    /// - Parameter fa: Computation to be run.
    /// - Returns: Result of running the computation.
    /// - Throws: Error happened during the execution of the computation, of the error type of the underlying `MonadError`.
    func runBlocking<F: UnsafeRun, A>(_ fa: @escaping () -> Kind<F, A>) throws -> A {
        return try F.runBlocking(on: self, fa)
    }
    
    /// Unsafely runs a computation in an asynchronous manner.
    ///
    /// - Parameters:
    ///   - fa: Computation to be run.
    ///   - callback: Callback to report the result of the evaluation.
    func runNonBlocking<F: UnsafeRun, A>(_ fa: @escaping () -> Kind<F, A>, _ callback: @escaping Callback<F.E, A>) {
        return F.runNonBlocking(on: self, fa, callback)
    }
}
