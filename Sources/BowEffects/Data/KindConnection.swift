import Bow

public typealias CancelToken<F> = Kind<F, Unit>

public enum OnCancel {
    case throwCancellationError
    case silent
}

public enum ConnectionCancelationError: Error {
    case userCancellation
}

public class KindConnection<F> {
    public func cancel() -> CancelToken<F> {
        fatalError("cancel must be implemented in subclasses")
    }

    public var isCanceled: Bool {
        fatalError("isCanceled must be implemented in subclasses")
    }

    public var isNotCanceled: Bool {
        return !isCanceled
    }

    public func push(_ token: CancelToken<F>) {
        fatalError("push must be implemented in subclasses")
    }

    public func push(_ tokens: CancelToken<F>...) {
        fatalError("push must be implemented in subclasses")
    }

    public func pushPair(_ lh: KindConnection<F>, _ rh: KindConnection<F>) {
        push(lh.cancel(), rh.cancel())
    }

    public func pushPair(_ lh: CancelToken<F>, _ rh: CancelToken<F>) {
        push(lh, rh)
    }

    public func pop() -> CancelToken<F> {
        fatalError("pop must be implemented in subclasses")
    }

    public func tryReactivate() -> Bool {
        fatalError("tryReactivate must be implemented in subclasses")
    }
}

public extension KindConnection where F: Applicative {
    public static func uncancelable() -> KindConnection<F> {
        return Uncancelable()
    }
}

public extension KindConnection where F: MonadDefer {
    public static func `default`(_ run: @escaping (CancelToken<F>) -> ()) -> KindConnection<F> {
        return DefaultKindConnection(run)
    }
}

private class Uncancelable<F: Applicative>: KindConnection<F> {
    override func cancel() -> CancelToken<F> {
        return F.pure(())
    }

    override var isCanceled: Bool {
        return false
    }

    override func push(_ token: CancelToken<F>) {}

    override func push(_ tokens: CancelToken<F>...) {}

    override func pop() -> CancelToken<F> {
        return F.pure(())
    }

    override func tryReactivate() -> Bool {
        return true
    }
}

private class DefaultKindConnection<F: MonadDefer>: KindConnection<F> {
    private let run: (CancelToken<F>) -> ()
    private let state: Atomic<[CancelToken<F>]?> = Atomic([])

    init(_ run: @escaping (CancelToken<F>) -> ()) {
        self.run = run
    }

    override func cancel() -> CancelToken<F> {
        guard let stack = state.getAndSet(nil), !stack.isEmpty else { return F.pure(()) }
        return cancelAll(stack)
    }

    private func cancelAll(_ array: [CancelToken<F>]) -> CancelToken<F> {
        return array.reduce(F.pure(())) { partial, next in next.flatMap { _ in partial } }
    }

    override var isCanceled: Bool {
        return state.value == nil
    }

    override func push(_ token: CancelToken<F>) {
        guard let _ = state.value else { return run(token) }
        state.mutate { old in old = [token] + (old ?? []) }
    }

    override func push(_ tokens: CancelToken<F>...) {
        push(cancelAll(tokens))
    }

    override func pop() -> CancelToken<F> {
        guard let stack = state.value, !stack.isEmpty else { return F.pure(()) }
        guard let first = stack.first else { return pop() }
        state.mutate { old in old = Array(old?.dropFirst() ?? []) }
        return first
    }

    override func tryReactivate() -> Bool {
        return state.setIfNil([])
    }
}
