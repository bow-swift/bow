import Bow
import Foundation

public protocol UnsafeRun: MonadError {
    static func runBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<Self, A>) throws -> A
    static func runNonBlocking<A>(on queue: DispatchQueue, _ fa: @escaping () -> Kind<Self, A>, _ callback: @escaping Callback<E, A>)
}

// MARK: Syntax for UnsafeRun

public extension Kind where F: UnsafeRun {
    static func runBlocking(on queue: DispatchQueue = .main, _ fa: @escaping () -> Kind<F, A>) throws -> A {
        return try F.runBlocking(on: queue, fa)
    }

    static func runNonBlocking(on queue: DispatchQueue = .main, _ fa: @escaping () -> Kind<F, A>, _ callback: @escaping Callback<F.E, A>) {
        return F.runNonBlocking(on: queue, fa, callback)
    }
}
