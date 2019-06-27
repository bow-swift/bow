import Bow
import Foundation

internal class CancelablePromise<F: Concurrent, A: Equatable>: Promise<F, A> where F.E: Equatable & PromiseError {
    private let state = Atomic<PromiseState<F.E, A>>(.pending(joiners: [:]))
    
    override func get() -> Kind<F, A> {
        return F.defer {
            switch self.state.value {
            case let .complete(value: value): return F.pure(value)
            case .pending: return F.cancelable { callback in
                let id = self.unsafeRegister(callback)
                return F.delay { self.unregister(id) }
            }
            case let .error(error): return F.raiseError(error)
            }
        }
    }
    
    override func tryGet() -> Kind<F, Option<A>> {
        return F.delay {
            let current = self.state.value
            switch current {
            case let .complete(value: a): return .some(a)
            default: return .none()
            }
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
    
    private func unsafeTryComplete(_ a: A) -> Kind<F, Bool> {
        let current = state.value
        guard case let .pending(joiners: joiners) = current else {
            return F.pure(false)
        }
        
        if state.compare(current, andSet: .complete(value: a)) {
            if !joiners.values.isEmpty {
                return callAll(joiners.arrayValues, with: .right(a)).map { _ in true }
            } else {
                return F.pure(true)
            }
        } else {
            return unsafeTryComplete(a)
        }
    }
    
    private func unsafeTryError(_ error: F.E) -> Kind<F, Bool> {
        let current = state.value
        guard case let .pending(joiners: joiners) = current else {
            return F.pure(false)
        }
        
        if state.compare(current, andSet: .error(error)) {
            if !joiners.values.isEmpty {
                return callAll(joiners.arrayValues, with: .left(error)).map { _ in true }
            } else {
                return F.pure(true)
            }
        } else {
            return unsafeTryError(error)
        }
    }
    
    private func unsafeRegister(_ callback: @escaping (Either<F.E, A>) -> ()) -> Token {
        let id = Token()
        if let result = register(id, callback) {
            callback(result)
        }
        return id
    }
    
    private func register(_ id: Token, _ callback: @escaping (Either<F.E, A>) -> ()) -> Either<F.E, A>? {
        let current = state.value
        switch current {
        case let .complete(value: value): return .right(value)
        case let .pending(joiners: joiners):
            let updated = PromiseState.pending(joiners: joiners + (id, callback))
            return !state.compare(current, andSet: updated) ? register(id, callback) : nil
        case let .error(error): return .left(error)
        }
    }
    
    private func unregister(_ id: Token) {
        let current = state.value
        guard case let .pending(joiners: joiners) = current else { return }
        
        let updated = PromiseState<F.E, A>.pending(joiners: joiners - id)
        return !state.compare(current, andSet: updated) ? unregister(id) : ()
    }
    
    private func callAll(_ array: [(Either<F.E, A>) -> ()], with value: Either<F.E, A>) -> Kind<F, ()> {
        let queue = DispatchQueue(label: "CancelablePromise")
        let fold = array.k().foldLeft(Option<Kind<F, Fiber<F, ()>>>.none()) { acc, callback in
            let task = queue.startFiber(F.delay { callback(value) })
            return acc.map { x in x.flatMap { _ in task } }^.orElse(.some(task))
        }
        return fold.map { x in x.map { _ in () } }^.getOrElse(F.pure(()))
    }
}

private enum PromiseState<E, A> {
    case pending(joiners: [Token: (Either<E, A>) -> ()])
    case complete(value: A)
    case error(E)
}

extension PromiseState: Equatable where A: Equatable, E: Equatable {
    static func == (lhs: PromiseState<E, A>, rhs: PromiseState<E, A>) -> Bool {
        switch (lhs, rhs) {
        case let (.pending(joiners: j1), .pending(joiners: j2)): return sameKeys(j1, j2)
        case let (.complete(value: v1), .complete(value: v2)): return v1 == v2
        case let (.error(e1), .error(e2)): return e1 == e2
        default: return false
        }
    }
    
    private static func sameKeys<K: Hashable, V>(_ lhs: [K: V], _ rhs: [K: V]) -> Bool {
        return lhs.keys == rhs.keys
    }
}
