import Foundation
import Bow

public typealias Disposable = () -> ()

public protocol ConcurrentEffect: Effect {
    static func runAsyncCancellable<A>(_ fa: Kind<Self, A>, _ callback: @escaping (Either<E, A>) -> Kind<Self, ()>) -> Kind<Self, Disposable>
}

// MARK: Syntax for ConcurrentEffect
public extension Kind where F: ConcurrentEffect {
    func runAsyncCancellable(_ callback: @escaping (Either<F.E, A>) -> Kind<F, ()>) -> Kind<F, Disposable> {
        return F.runAsyncCancellable(self, callback)
    }
}
