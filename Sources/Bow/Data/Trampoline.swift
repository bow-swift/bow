public class Trampoline<A> {
    public static func done(_ value: A) -> Trampoline<A> {
        Done(value)
    }
    
    public static func `defer`(_ f: @escaping () -> Trampoline<A>) -> Trampoline<A> {
        Defer(f)
    }
    
    public static func later(_ f: @escaping () -> A) -> Trampoline<A> {
        .defer { .done(f()) }
    }
    
    public final func run() -> A {
        var trampoline = self
        while true {
            let step = trampoline.step()
            if step.isLeft {
                trampoline = step.leftValue()
            } else {
                return step.rightValue
            }
        }
    }

    internal func step() -> Either<() -> Trampoline<A>, A> {
        fatalError("Implement step in subclasses")
    }

    public func flatMap<B>(_ f: @escaping (A) -> Trampoline<B>) -> Trampoline<B> {
        FlatMap(self, f)
    }

    public func map<B>(_ f: @escaping (A) -> B) -> Trampoline<B> {
        flatMap { a in .done(f(a)) }
    }
}


private final class Done<A>: Trampoline<A> {
    let result: A

    init(_ result: A) {
        self.result = result
    }

    override func step() -> Either<() -> Trampoline<A>, A> {
        .right(result)
    }
}


private final class Defer<A>: Trampoline<A> {
    let deferred: () -> Trampoline<A>

    init(_ deferred: @escaping () -> Trampoline<A>) {
        self.deferred = deferred
    }

    override func step() -> Either<() -> Trampoline<A>, A> {
        .left(deferred)
    }
}


private final class FlatMap<A, B>: Trampoline<B> {
    let trampoline: Trampoline<A>
    let continuation: (A) -> Trampoline<B>

    init(_ trampoline: Trampoline<A>, _ continuation: @escaping (A) -> Trampoline<B>) {
        self.trampoline = trampoline
        self.continuation = continuation
    }

    override func flatMap<C>(_ f: @escaping (B) -> Trampoline<C>) -> Trampoline<C> {
        let continuation = self.continuation
        return FlatMap<A, C>(trampoline) { a in
            continuation(a).flatMap(f)
        }
    }

    override func step() -> Either<() -> Trampoline<B>, B> {
        switch trampoline {
        case let done as Done<A>:
            return .left { [continuation] in
                continuation(done.result)
            }
        case let next as Defer<A>:
            return .left { [continuation] in
                next.deferred().flatMap(continuation)
            }
        default:
            fatalError("Invalid Trampoline case")
        }
    }
}
