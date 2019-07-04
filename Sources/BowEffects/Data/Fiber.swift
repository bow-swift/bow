import Foundation
import Bow

open class Fiber<F, A> {
    public static func create(join: @escaping () -> Kind<F, A>, cancel: @escaping () -> CancelToken<F>) -> Fiber<F, A> {
        return DefaultFiber(join: join, cancel: cancel)
    }
    
    internal init() {}

    open func join() -> Kind<F, A> {
        fatalError("join must be implemented in subclasses")
    }

    open func cancel() -> CancelToken<F> {
        fatalError("cancel must be implemented in subclasses")
    }

    public func get() -> (Kind<F, A>, CancelToken<F>) {
        return (join(), cancel())
    }
}

private class DefaultFiber<F, A>: Fiber<F, A> {
    private let fJoin: () -> Kind<F, A>
    private let fCancel: () -> CancelToken<F>

    init(join: @escaping () -> Kind<F, A>, cancel: @escaping () -> CancelToken<F>) {
        self.fJoin = join
        self.fCancel = cancel
    }

    override func join() -> Kind<F, A> {
        return fJoin()
    }

    override func cancel() -> CancelToken<F> {
        return fCancel()
    }
}
