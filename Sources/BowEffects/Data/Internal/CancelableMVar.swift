import Foundation
import Bow

class CancelableMVar<F: Concurrent, A: Equatable>: MVar<F, A> {
    private let state: Atomic<State<A>>

    static func invoke(_ a: A) -> Kind<F, MVar<F, A>> {
        return F.delay { CancelableMVar(State.invoke(a)) }
    }

    static func empty() -> Kind<F, MVar<F, A>> {
        return F.delay { CancelableMVar(State.empty()) }
    }

    private init(_ initial: State<A>) {
        self.state = Atomic(initial)
    }

    override var isEmpty: Kind<F, Bool> {
        switch state.value {
        case .waitForPut: return F.pure(true)
        case .waitForTake: return F.pure(false)
        }
    }

    override var isNotEmpty: Kind<F, Bool> {
        switch state.value {
        case .waitForPut: return F.pure(false)
        case .waitForTake: return F.pure(true)
        }
    }

    override func put(_ a: A) -> Kind<F, ()> {
        return tryPut(a).flatMap { didPut in
            if didPut {
                return F.pure(())
            } else {
                return F.cancelableF { cb in self.unsafePut(a, { either in either.fold({ _ in }, { _ in cb(.right(())) }) }) }
            }
        }
    }

    override func tryPut(_ a: A) -> Kind<F, Bool> {
        return F.defer { self.unsafeTryPut(a) }
    }

    override func take() -> Kind<F, A> {
        return tryTake().flatMap { option in
            option.fold({ F.cancelableF(self.unsafeTake) }, F.pure)
        }
    }

    override func tryTake() -> Kind<F, Option<A>> {
        return F.defer(unsafeTryTake)
    }

    override func read() -> Kind<F, A> {
        return F.cancelable(unsafeRead)
    }

    private func unsafeTryPut(_ a: A) -> Kind<F, Bool> {
        let current = state.value
        switch current {
        case .waitForTake: return F.pure(false)
        case let .waitForPut(reads: reads, takes: takes):
            let first = takes.first
            let update: State<A>
            if takes.isEmpty {
                update = .invoke(a)
            } else {
                let rest = toDict(takes.dropFirst())
                if rest.isEmpty {
                    update = .empty()
                } else {
                    update = .waitForPut(reads: [:], takes: rest)
                }
            }

            if !state.compareAndSet(current, update) {
                return unsafeTryPut(a)
            } else if first != nil || !reads.isEmpty {
                return callPutAndAllReaders(a, first?.value, reads)
            } else {
                return F.pure(true)
            }
        }
    }

    private func unsafePut(_ a: A, _ onPut: @escaping Callback<Never, ()>) -> Kind<F, CancelToken<F>> {
        let current = state.value
        switch current {
        case let .waitForTake(value: value, listeners: listeners):
            let id = Token()
            let newDict = listeners + (id, (a, onPut))
            if state.compareAndSet(current, .waitForTake(value: value, listeners: newDict)) {
                return F.pure(F.delay { self.unsafeCancelPut(id) })
            } else {
                return unsafePut(a, onPut)
            }
        case let .waitForPut(reads: reads, takes: takes):
            let first = takes.first
            let update: State<A>
            if takes.isEmpty {
                update = .invoke(a)
            } else {
                let rest = toDict(takes.dropFirst())
                if rest.isEmpty {
                    update = .empty()
                } else {
                    update = .waitForPut(reads: [:], takes: rest)
                }
            }

            if state.compareAndSet(current, update) {
                if first != nil || !reads.isEmpty {
                    return callPutAndAllReaders(a, first?.value, reads).map { _ in
                        onPut(.right(()))
                        return F.pure(())
                    }
                } else {
                    onPut(.right(()))
                    return F.pure(F.pure(()))
                }
            } else {
                return unsafePut(a, onPut)
            }
        }
    }

    private func unsafeCancelPut(_ id: Token) {
        let current = state.value
        switch current {
        case let .waitForTake(value: value, listeners: listeners):
            let update = State.waitForTake(value: value, listeners: listeners - id)
            if !state.compareAndSet(current, update) {
                return unsafeCancelPut(id)
            }
        case .waitForPut: return
        }
    }

    private func unsafeTryTake() -> Kind<F, Option<A>> {
        let current = state.value
        switch current {
        case let .waitForTake(value: value, listeners: listeners):
            if let (ax, notify) = listeners.values.first {
                let xs = toDict(listeners.dropFirst())
                if state.compareAndSet(current, .waitForTake(value: ax, listeners: xs)) {
                    return DispatchQueue.global().startFiber(F.delay {
                        notify(.right(()))
                    }).map { _ in .some(value) }
                } else {
                    return unsafeTryTake()
                }
            } else {
                if state.compareAndSet(current, State.empty()) {
                    return F.pure(.some(value))
                } else {
                    return unsafeTryTake()
                }
            }
        case .waitForPut:
            return F.pure(.none())
        }
    }

    private func unsafeTake(_ onTake: @escaping Callback<F.E, A>) -> Kind<F, CancelToken<F>> {
        return unsafeTake { (either: Either<Never, A>) in
            either.fold({ _ in }, { a in onTake(.right(a)) })
        }
    }

    private func unsafeTake(_ onTake: @escaping Callback<Never, A>) -> Kind<F, CancelToken<F>> {
        let current = state.value
        switch current {
        case let .waitForTake(value: value, listeners: listeners):
            if let (ax, notify) = listeners.values.first {
                let xs = toDict(listeners.dropFirst())
                if state.compareAndSet(current, .waitForTake(value: ax, listeners: xs)) {
                    return DispatchQueue.global().startFiber(F.delay { notify(.right(())) }).map { _ in
                        onTake(.right(value))
                        return F.pure(())
                    }
                } else {
                    return unsafeTake(onTake)
                }
            } else {
                if state.compareAndSet(current, State.empty()) {
                    onTake(.right(value))
                    return F.pure(F.pure(()))
                } else {
                    return unsafeTake(onTake)
                }
            }
        case let .waitForPut(reads: reads, takes: takes):
            let id = Token()
            let newQueue = takes + (id, onTake)
            if state.compareAndSet(current, .waitForPut(reads: reads, takes: newQueue)) {
                return F.pure(F.delay { self.unsafeCancelTake(id) })
            } else {
                return unsafeTake(onTake)
            }
        }
    }

    private func unsafeCancelTake(_ id: Token) {
        let current = state.value
        switch current {
        case let .waitForPut(reads: reads, takes: takes):
            let newDict = takes - id
            let update = State<A>.waitForPut(reads: reads, takes: newDict)
            if !state.compareAndSet(current, update) {
                unsafeCancelTake(id)
            }
        case .waitForTake: return
        }
    }

    private func unsafeRead(_ onRead: @escaping Callback<F.E, A>) -> Kind<F, ()> {
        return unsafeRead { (either: Either<Never, A>) in
            either.fold({ _ in }, { a in onRead(.right(a)) })
        }
    }

    private func unsafeRead(_ onRead: @escaping Callback<Never, A>) -> Kind<F, ()> {
        let current = state.value
        switch current {
        case let .waitForTake(value: value, listeners: _):
            onRead(.right(value))
            return F.pure(())
        case let .waitForPut(reads: reads, takes: takes):
            let id = Token()
            let newReads = reads + (id, onRead)
            if state.compareAndSet(current, .waitForPut(reads: newReads, takes: takes)) {
                return F.delay { self.unsafeCancelRead(id) }
            } else {
                return unsafeRead(onRead)
            }
        }
    }

    private func unsafeCancelRead(_ id: Token) {
        let current = state.value
        switch current {
        case let .waitForPut(reads: reads, takes: takes):
            let newDict = reads - id
            let update = State<A>.waitForPut(reads: newDict, takes: takes)
            if !state.compareAndSet(current, update) {
                return unsafeCancelRead(id)
            }
        case .waitForTake: return
        }
    }

    private func callPutAndAllReaders(_ a: A, _ put: Callback<Never, A>?, _ reads: [Token: Callback<Never, A>]) -> Kind<F, Bool> {
        let value = Either<Never, A>.right(a)
        let callbacks = Array(reads.values)
        return callAll(callbacks, value).flatMap { _ in
            if let put = put {
                return DispatchQueue.global().startFiber(F.delay { put(value) }).map(constant(true))
            } else {
                return F.pure(true)
            }
        }
    }

    private func callAll(_ sequence: [Callback<Never, A>], _ value: Either<Never, A>) -> Kind<F, ()> {
        return sequence.k().foldLeft(nil, { (acc: Kind<F, Fiber<F, ()>>?, cb: @escaping Callback<Never, A>) in
            let task = DispatchQueue.global().startFiber(F.delay { cb(value) })
            return acc?.flatMap { _ in task } ?? task
        })?.map { _ in () } ?? F.pure(())
    }
}

private enum State<A: Equatable> {
    case waitForPut(reads: [Token: Callback<Never, A>], takes: [Token: Callback<Never, A>])
    case waitForTake(value: A, listeners: [Token: (A, Callback<Never, ()>)])

    static func invoke(_ a: A) -> State<A> {
        return .waitForTake(value: a, listeners: [:])
    }

    static func empty() -> State<A> {
        return .waitForPut(reads: [:], takes: [:])
    }
}

extension State: Equatable {
    static func == (lhs: State<A>, rhs: State<A>) -> Bool {
        switch (lhs, rhs) {
        case let (.waitForPut(reads: lreads, takes: ltakes), .waitForPut(reads: rreads, takes: rtakes)):
            if lreads.count != rreads.count { return false }
            if ltakes.count != rtakes.count { return false }
            for lread in lreads {
                guard let rread = rreads[lread.key] else { return false }
                if "\(lread.value)" != "\(rread)" { return false }
            }
            for ltake in ltakes {
                guard let rtake = rtakes[ltake.key] else { return false }
                if "\(ltake.value)" != "\(rtake)" { return false }
            }
            return true
        case let (.waitForTake(value: lvalue, listeners: llisteners), .waitForTake(value: rvalue, listeners: rlisteners)):
            if lvalue != rvalue { return false }
            if llisteners.count != rlisteners.count { return false }
            for llistener in llisteners {
                guard let rlistener = rlisteners[llistener.key] else { return false }
                if llistener.value.0 != rlistener.0 { return false }
                if "\(llistener.value.1)" != "\(rlistener.1)" { return false }
            }
            return true
        default:
            return false
        }
    }
}

private struct Token: Hashable {}

extension Token: CustomStringConvertible {
    var description: String {
        return "Token(\(self.hashValue))"
    }
}

private func -<K: Hashable, V>(_ dictionary: [K: V], _ key: K) -> [K: V] {
    var newDict: [K: V] = dictionary
    newDict.removeValue(forKey: key)
    return newDict
}

private func +<K: Hashable, V>(_ dictionary: [K: V], _ element: (K, V)) -> [K: V] {
    var newDict: [K: V] = dictionary
    newDict[element.0] = element.1
    return newDict
}

private func toDict<K: Hashable, V>(_ slice: Slice<[K: V]>) -> [K: V] {
    var dict: [K: V] = [:]
    for (k, v) in slice {
        dict[k] = v
    }
    return dict
}
