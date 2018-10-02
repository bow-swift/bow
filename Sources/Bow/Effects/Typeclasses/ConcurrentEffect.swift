import Foundation

public typealias Disposable = () -> Unit

public protocol ConcurrentEffect : Effect {
    func runAsyncCancellable<A>(_ fa : Kind<F, A>, _ callback : @escaping (Either<Error, A>) -> Kind<F, Unit>) -> Kind<F, Disposable>
}
