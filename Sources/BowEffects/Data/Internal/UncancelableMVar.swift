import Bow

class UncancelableMVar<F: Async, A: Equatable>: MVar<F, A> {
    private let stateRef: Atomic<State<F, A>>

    static func invoke(_ initial: A) -> Kind<F, MVar<F, A>> {
        return F.delay {
            UncancelableMVar(State.invoke(initial))
        }
    }

    static func empty() -> Kind<F, MVar<F, A>> {
        return F.delay { UncancelableMVar(State.empty()) }
    }

    private init(_ initial: State<F, A>) {
        self.stateRef = Atomic(initial)
        super.init()
    }

    override var isEmpty: Kind<F, Bool> {
        return F.delay {
            switch self.stateRef.value {
            case .waitForPut: return true
            case .waitForTake: return false
            }
        }
    }

    override var isNotEmpty: Kind<F, Bool> {
        return F.delay {
            switch self.stateRef.value {
            case .waitForPut: return false
            case .waitForTake: return true
            }
        }
    }

    override func put(_ a: A) -> Kind<F, ()> {
        return tryPut(a).flatMap { result in
            if result {
                return F.pure(())
            } else {
                return F.asyncF { cb in self.unsafePut(a, cb) }
            }
        }
    }

    override func tryPut(_ a: A) -> Kind<F, Bool> {
        return F.defer { self.unsafeTryPut(a) }
    }

    override func take() -> Kind<F, A> {
        return tryTake().flatMap { option in
            option.fold({ F.asyncF(self.unsafeTake)}, F.pure)
        }
    }

    override func tryTake() -> Kind<F, Option<A>> {
        return F.defer(unsafeTryTake)
    }

    override func read() -> Kind<F, A> {
        return F.async(unsafeRead)
    }

    private func unsafeTryPut(_ a: A) -> Kind<F, Bool> {
        let current = stateRef.value
        switch current {
        case .waitForTake: return F.pure(false)
        case let .waitForPut(reads: reads, takes: takes):
            let first = takes.first
            let update: State<F, A>
            if takes.isEmpty {
                update = State.invoke(a)
            } else {
                let rest = Array(takes.dropFirst())
                if rest.isEmpty {
                    update = State.empty()
                } else {
                    update = .waitForPut(reads: [], takes: rest)
                }
            }

            if !stateRef.compareAndSet(current, update) {
                return unsafeTryPut(a)
            } else if let first = first, !reads.isEmpty {
                return streamPutAndReads(a, reads: reads, first: first)
            } else {
                return F.pure(true)
            }
        }
    }

    private func unsafePut(_ a: A, _ onPut: @escaping Callback<F.E, ()>) -> Kind<F, ()> {
        let current = stateRef.value
        switch current {
        case let .waitForTake(value: value, puts: puts):
            let update = State<F, A>.waitForTake(value: value, puts: puts + [(a, onPut)])
            if !stateRef.compareAndSet(current, update) {
                return unsafePut(a, onPut)
            } else {
                return F.pure(())
            }
        case let .waitForPut(reads: reads, takes: takes):
            let first = takes.first
            let update: State<F, A>
            if takes.isEmpty {
                update = State.invoke(a)
            } else {
                let rest = Array(takes.dropFirst())
                if rest.isEmpty {
                    update = State.empty()
                } else {
                    update = .waitForPut(reads: [], takes: rest)
                }
            }

            if !stateRef.compareAndSet(current, update) {
                return unsafePut(a, onPut)
            } else {
                return streamPutAndReads(a, reads: reads, first: first).map { _ in onPut(.right(())) }
            }
        }
    }

    private func unsafeTryTake() -> Kind<F, Option<A>> {
        let current = stateRef.value
        switch current {
        case let .waitForTake(value: value, puts: puts):
            if let (ax, notify) = puts.first {
                let xs = Array(puts.dropFirst())
                let update = State<F, A>.waitForTake(value: ax, puts: xs)
                if stateRef.compareAndSet(current, update) {
                    return F.async({ cb in cb(.right(())) }).map { _ in
                        notify(.right(()))
                        return .some(value)
                    }
                } else {
                    return unsafeTryTake()
                }
            } else {
                if stateRef.compareAndSet(current, State.empty()) {
                    return F.pure(.some(value))
                } else {
                    return unsafeTryTake()
                }
            }
        case .waitForPut:
            return F.pure(.none())
        }
    }

    private func unsafeTake(_ onTake: @escaping Callback<F.E, A>) -> Kind<F, ()> {
        let current = stateRef.value
        switch current {
        case let .waitForTake(value: value, puts: puts):
            if let (ax, notify) = puts.first {
                let xs = Array(puts.dropFirst())
                let update = State<F, A>.waitForTake(value: ax, puts: xs)
                if stateRef.compareAndSet(current, update) {
                    return F.async { cb in cb(.right(())) }.map { _ in
                        notify(.right(()))
                        onTake(.right(value))
                    }
                } else {
                    return unsafeTake(onTake)
                }
            } else {
                if stateRef.compareAndSet(current, State.empty()) {
                    onTake(.right(value))
                    return F.pure(())
                } else {
                    return unsafeTake(onTake)
                }
            }
        case let .waitForPut(reads: reads, takes: takes):
            if !stateRef.compareAndSet(current, .waitForPut(reads: reads, takes: takes + [onTake])) {
                return unsafeTake(onTake)
            } else {
                return F.pure(())
            }
        }
    }

    private func unsafeRead(_ onRead: @escaping Callback<F.E, A>) {
        let current = stateRef.value
        switch current {
        case let .waitForTake(value: value, puts: _):
            onRead(.right(value))
        case let .waitForPut(reads: reads, takes: takes):
            if !stateRef.compareAndSet(current, State.waitForPut(reads: reads + [onRead], takes: takes)) {
                return unsafeRead(onRead)
            }
        }
    }

    private func streamPutAndReads(_ a: A, reads: [Callback<F.E, A>], first: Callback<F.E, A>?) -> Kind<F, Bool> {
        return F.async { cb in cb(.right(())) }.map { _ in
            let value = Either<F.E, A>.right(a)
            reads.forEach { cb in cb(value) }
            first?(value)
            return true
        }
    }
}

private enum State<F: Async, A> {
    case waitForPut(reads: [Callback<F.E, A>], takes: [Callback<F.E, A>])
    case waitForTake(value: A, puts: [(A, Callback<F.E, ()>)])

    static func invoke(_ a: A) -> State<F, A> {
        return .waitForTake(value: a, puts: [])
    }

    static func empty() -> State<F, A> {
        return .waitForPut(reads: [], takes: [])
    }
}

extension State: Equatable where A: Equatable {
    static func ==(lhs: State<F, A>, rhs: State<F, A>) -> Bool {
        switch (lhs, rhs) {
        case let (.waitForPut(reads: lreads, takes: ltakes), .waitForPut(reads: rreads, takes: rtakes)):
            if lreads.count != rreads.count { return false }
            if ltakes.count != rtakes.count { return false }
            let compareReads = zip(lreads, rreads).map { (input) -> Bool in let (a, b) = input; return "\(a)" == "\(b)" }.reduce(true, and)
            let compareTakes = zip(ltakes, rtakes).map { (input) -> Bool in let (a, b) = input; return "\(a)" == "\(b)" }.reduce(true, and)
            return compareReads && compareTakes
        case let (.waitForTake(value: lvalue, puts: lputs), .waitForTake(value: rvalue, puts: rputs)):
            if lputs.count != rputs.count { return false }
            let compareValues = lvalue == rvalue
            let comparePuts = zip(lputs, rputs).map { (input) -> Bool in let (a, b) = input; return "\(a)" == "\(b)" }.reduce(true, and)
            return compareValues && comparePuts
        default:
            return false
        }
    }
}

