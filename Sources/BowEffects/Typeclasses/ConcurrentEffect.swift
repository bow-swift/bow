import Foundation
import Bow

public typealias Disposable = () -> ()

public protocol ConcurrentEffect : Effect {
    func runAsyncCancellable<A>(_ fa : Kind<F, A>, _ callback : @escaping (Either<Error, A>) -> Kind<F, ()>) -> Kind<F, Disposable>
}
