import Bow

internal class UnsafePromise<E: Equatable, A: Equatable> {
    private let state = Atomic(PromiseState<E, A>.empty)
    
    func get(_ callback: @escaping (Either<E, A>) -> ()) {
        func go() {
            let oldState = state.value
            switch oldState {
            case .empty:
                return !state.compare(oldState, andSet: .waiting(joiners: [callback])) ? go() : ()
            case let .waiting(joiners: joiners):
                return !state.compare(oldState, andSet: .waiting(joiners: joiners + [callback])) ? go() : ()
            case let .full(result):
                return callback(result)
            }
        }
        
        return go()
    }
    
    func complete(_ value: Either<E, A>) throws {
        func go() throws {
            let oldState = state.value
            switch oldState {
            case .empty:
                return !state.compare(oldState, andSet: .full(value)) ? try go() : ()
            case let .waiting(joiners: joiners):
                if state.compare(oldState, andSet: .full(value)) {
                    joiners.forEach { joiner in joiner(value) }
                } else {
                    try go()
                }
            case .full:
                throw UnsafePromiseError.alreadyFulfilled
            }
        }
        
        return try go()
    }
}

internal enum UnsafePromiseError: Error {
    case alreadyFulfilled
}

private enum PromiseState<E, A> {
    case empty
    case waiting(joiners: [(Either<E, A>) -> ()])
    case full(Either<E, A>)
}

extension PromiseState: Equatable where A: Equatable, E: Equatable {
    static func == (lhs: PromiseState<E, A>, rhs: PromiseState<E, A>) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty): return true
        case let (.full(r1), .full(r2)): return r1 == r2
        default:
            return false
        }
    }
}
