import Foundation
import Bow

/// A callback that receives an error or a value.
public typealias Callback<E, A> = (Either<E, A>) -> ()

/// An asynchronous operation that might fail.
public typealias Proc<E, A> = (@escaping Callback<E, A>) -> ()

/// An asynchronous operation that might fail.
public typealias ProcF<F, E, A> = (@escaping Callback<E, A>) -> Kind<F, ()>

/// Async models how a data type runs an asynchronous computation that may fail, described by the `Proc` signature.
public protocol Async: MonadDefer {
    /// Suspends side effects in the provided registration function. The parameter function is injected with a side-effectful callback for signaling the result of an asynchronous process.
    ///
    /// - Parameter procf: Asynchronous operation.
    /// - Returns: A computation describing the asynchronous operation.
    static func asyncF<A>(_ procf: @escaping ProcF<Self, E, A>) -> Kind<Self, A>
    
    /// Switches the evaluation of a computation to a different `DispatchQueue`.
    ///
    /// - Parameters:
    ///   - fa: A computation.
    ///   - queue: A Dispatch Queue.
    /// - Returns: A computation that will run on the provided queue.
    static func continueOn<A>(_ fa: Kind<Self, A>, _ queue: DispatchQueue) -> Kind<Self, A>
}

public extension Async {
    /// Suspends side effects in the provided registration function. The parameter function is injected with a side-effectful callback for signaling the result of an asynchronous process.
    ///
    /// - Parameter proc: Asynchronous operation.
    /// - Returns: A computation describing the asynchronous operation.
    static func async<A>(_ proc: @escaping Proc<E, A>) -> Kind<Self, A> {
        return asyncF { cb in
            later {
                proc(cb)
            }
        }
    }
    
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter queue: Dispatch queue which the computation must be sent to.
    /// - Parameter f: Function returning a value.
    /// - Returns: A computation that defers the execution of the provided function.
    static func `defer`<A>(_ queue: DispatchQueue, _ f: @escaping () -> Kind<Self, A>) -> Kind<Self, A> {
        return pure(()).continueOn(queue).flatMap(f)
    }
    
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter queue: Dispatch queue which the computation must be sent to.
    /// - Parameter f: Function returning a value.
    /// - Returns: A computation that defers the execution of the provided function.
    static func later<A>(_ queue: DispatchQueue, _ f: @escaping () throws -> A) -> Kind<Self, A> {
        return Self.defer(queue) {
            do {
                return pure(try f())
            } catch let e as Self.E {
                return raiseError(e)
            } catch {
                fatalError("Unexpected error happened: \(error)")
            }
        }
    }
    
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter queue: Dispatch queue which the computation must be sent to.
    /// - Parameter f: A function that provides a value or an error.
    /// - Returns: A computation that defers the execution of the provided value.
    static func delayOrRaise<A>(_ queue: DispatchQueue, _ f: @escaping () -> Either<E, A>) -> Kind<Self, A> {
        return Self.defer(queue) { f().fold(raiseError, pure) }
    }
    
    /// Provides an asynchronous computation that never finishes.
    ///
    /// - Returns: An asynchronous computation that never finishes.
    static func never<A>() -> Kind<Self, A> {
        return async { _ in }
    }
}

// MARK: Syntax for Async

public extension Kind where F: Async {
    /// Suspends side effects in the provided registration function. The parameter function is injected with a side-effectful callback for signaling the result of an asynchronous process.
    ///
    /// - Parameter procf: Asynchronous operation.
    /// - Returns: A computation describing the asynchronous operation.
    static func asyncF(_ procf: @escaping ProcF<F, F.E, A>) -> Kind<F, A> {
        return F.asyncF(procf)
    }
    
    /// Switches the evaluation of a computation to a different `DispatchQueue`.
    ///
    /// - Parameters:
    ///   - queue: A Dispatch Queue.
    /// - Returns: A computation that will run on the provided queue.
    func continueOn(_ queue: DispatchQueue) -> Kind<F, A> {
        return F.continueOn(self, queue)
    }
    
    /// Suspends side effects in the provided registration function. The parameter function is injected with a side-effectful callback for signaling the result of an asynchronous process.
    ///
    /// - Parameter proc: Asynchronous operation.
    /// - Returns: A computation describing the asynchronous operation.
    static func async(_ fa: @escaping Proc<F.E, A>) -> Kind<F, A> {
        return F.async(fa)
    }
    
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter queue: Dispatch queue which the computation must be sent to.
    /// - Parameter f: Function returning a value.
    /// - Returns: A computation that defers the execution of the provided function.
    static func `defer`(_ queue: DispatchQueue, _ f: @escaping () -> Kind<F, A>) -> Kind<F, A> {
        return F.defer(queue, f)
    }
    
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter queue: Dispatch queue which the computation must be sent to.
    /// - Parameter f: Function returning a value.
    /// - Returns: A computation that defers the execution of the provided function.
    static func later(_ queue: DispatchQueue, _ f: @escaping () throws -> A) -> Kind<F, A> {
        return F.later(queue, f)
    }
    
    /// Provides a computation that evaluates the provided function on every run.
    ///
    /// - Parameter queue: Dispatch queue which the computation must be sent to.
    /// - Parameter f: A function that provides a value or an error.
    /// - Returns: A computation that defers the execution of the provided value.
    static func delayOrRaise<A>(_ queue: DispatchQueue, _ f: @escaping () -> Either<F.E, A>) -> Kind<F, A> {
        return F.delayOrRaise(queue, f)
    }
    
    /// Provides an asynchronous computation that never finishes.
    ///
    /// - Returns: An asynchronous computation that never finishes.
    static func never() -> Kind<F, A> {
        return F.never()
    }
}

// MARK: Async syntax for DispatchQueue

public extension DispatchQueue {
    /// Provides an asynchronous computation that runs on this queue.
    ///
    /// - Returns: An asynchronous computation that runs on this queue.
    func shift<F: Async>() -> Kind<F, ()> {
        return F.later(self) {}
    }
}
