import Bow

internal class UncancelablePromise<F: Async, A: Equatable>: Promise<F, A> where F.E: Equatable & PromiseError {
    private let state = Atomic<PromiseState<F.E, A>>(.pending(joiners: []))
    
    override func get() -> Kind<F, A> {
        return F.async { callback in
            if let result = self.register(callback) {
                callback(result)
            }
        }
    }
    
    override func tryGet() -> Kind<F, Option<A>> {
        let oldState = state.value
        switch oldState {
        case let .complete(value: value): return F.pure(.some(value))
        default:
            return F.pure(.none())
        }
    }
    
    override func complete(_ a: A) -> Kind<F, ()> {
        return tryComplete(a).flatMap { didComplete in
            if didComplete {
                return F.pure(())
            } else {
                return F.raiseError(F.E.alreadyFulfilled)
            }
        }
    }
    
    override func tryComplete(_ a: A) -> Kind<F, Bool> {
        return F.defer { self.unsafeTryComplete(a) }
    }
    
    override func error<E: Error>(_ e: E) -> Kind<F, ()> {
        return tryError(e).flatMap { didError in
            if didError {
                return F.pure(())
            } else {
                return F.raiseError(F.E.alreadyFulfilled)
            }
        }
    }
    
    override func tryError<E: Error>(_ e: E) -> Kind<F, Bool> {
        if let error = e as? F.E {
            return F.defer { self.unsafeTryError(error) }
        } else {
            return F.pure(false)
        }
    }
    
    private func register(_ callback: @escaping (Either<F.E, A>) -> ()) -> Either<F.E, A>? {
        let current = state.value
        switch current {
        case let .complete(value: value): return .right(value)
        case let .pending(joiners: joiners):
            let updated = PromiseState<F.E, A>.pending(joiners: joiners + [callback])
            if !state.compare(current, andSet: updated) {
                return register(callback)
            } else {
                return nil
            }
        case let .error(error): return .left(error)
        }
    }
    
    private func unsafeTryComplete(_ a: A) -> Kind<F, Bool> {
        return unsafeTry(.complete(value: a), .right(a))
    }
    
    private func unsafeTryError(_ e: F.E) -> Kind<F, Bool> {
        return unsafeTry(.error(e), .left(e))
    }
    
    private func unsafeTry(_ newState: PromiseState<F.E, A>, _ result: Either<F.E, A>) -> Kind<F, Bool> {
        let current = state.value
        guard case let .pending(joiners: joiners) = current else {
            return F.pure(false)
        }
        
        if state.compare(current, andSet: newState) {
            return F.delay {
                joiners.forEach { joiner in joiner(result) }
                return true
            }
        } else {
            return F.pure(true)
        }
    }
}

private enum PromiseState<E, A> {
    case pending(joiners: [(Either<E, A>) -> ()])
    case complete(value: A)
    case error(E)
}

extension PromiseState: Equatable where E: Equatable, A: Equatable {
    static func == (lhs: PromiseState<E, A>, rhs: PromiseState<E, A>) -> Bool {
        switch (lhs, rhs) {
        case let (.pending(joiners: j1), .pending(joiners: j2)):
            if j1.count == j2.count {
                return zip(j1, j2).map { x in "\(String(describing: x.0))" == "\(String(describing: x.1))" }.reduce(true, and)
            } else {
                return false
            }
        case let (.complete(value: v1), .complete(value: v2)): return v1 == v2
        case let (.error(e1), .error(e2)): return e1 == e2
        default: return false
        }
    }
}
