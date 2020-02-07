public class Trampoline<A> {
    public static func done(_ value: A) -> Trampoline<A> {
        Done(value)
    }
    
    public static func `defer`(_ f: @escaping () throws -> Trampoline<A>) -> Trampoline<A> {
        Defer(f)
    }
    
    public static func later(_ f: @escaping () throws -> A) -> Trampoline<A> {
        .defer { .done(try f()) }
    }
    
    public final func run() throws -> A {
        var trampoline = self
        while true {
            let step = trampoline.step()
            if step.isLeft {
                trampoline = try step.leftValue()
            } else {
                return step.rightValue
            }
        }
    }

    internal func step() -> Either<() throws -> Trampoline<A>, A> {
        fatalError("Implement step in subclasses")
    }

    public func flatMap<B>(_ f: @escaping (A) throws -> Trampoline<B>) throws -> Trampoline<B> {
        FlatMap(self, f)
    }

    public func map<B>(_ f: @escaping (A) throws -> B) throws -> Trampoline<B> {
        try flatMap { a in .done(try f(a)) }
    }
}


private final class Done<A>: Trampoline<A> {
    let result: A

    init(_ result: A) {
        self.result = result
    }

    override func step() -> Either<() throws -> Trampoline<A>, A> {
        .right(result)
    }
}


private final class Defer<A>: Trampoline<A> {
    let deferred: () throws -> Trampoline<A>

    init(_ deferred: @escaping () throws -> Trampoline<A>) {
        self.deferred = deferred
    }

    override func step() -> Either<() throws -> Trampoline<A>, A> {
        .left(deferred)
    }
}


private final class FlatMap<A, B>: Trampoline<B> {
    let trampoline: Trampoline<A>
    let continuation: (A) throws -> Trampoline<B>

    init(_ trampoline: Trampoline<A>, _ continuation: @escaping (A) throws -> Trampoline<B>) {
        self.trampoline = trampoline
        self.continuation = continuation
    }

    override func flatMap<C>(_ f: @escaping (B) throws -> Trampoline<C>) throws -> Trampoline<C> {
        let continuation = self.continuation
        return FlatMap<A, C>(trampoline) { a in
            try continuation(a).flatMap(f)
        }
    }

    override func step() -> Either<() throws -> Trampoline<B>, B> {
        switch trampoline {
        case let done as Done<A>:
            return .left { [continuation] in
                try continuation(done.result)
            }
        case let next as Defer<A>:
            return .left { [continuation] in
                try next.deferred().flatMap(continuation)
            }
        default:
            fatalError("Invalid Trampoline case")
        }
    }
}
