/// The Trampoline type helps us overcome stack safety issues of recursive calls by transforming them into loops.
public class Trampoline<A> {
    /// Creates a Trampoline that does not need to recurse and provides the final result.
    ///
    /// - Parameter value: Result of the computation.
    /// - Returns: A Trampoline that provides a value and stops recursing.
    public static func done(_ value: A) -> Trampoline<A> {
        Done(value)
    }
    
    /// Creates a Trampoline that performs a computation and needs to recurse.
    ///
    /// - Parameter f: Function describing the recursive step.
    /// - Returns: A Trampoline that describes a recursive step.
    public static func `defer`(_ f: @escaping () -> Trampoline<A>) -> Trampoline<A> {
        Defer(f)
    }
    
    /// Creates a Trampoline that performs a computation in a moment in the future.
    ///
    /// - Parameter f: Function to compute the value wrapped in this Trampoline.
    /// - Returns: A Trampoline that delays the obtention of a value and stops recursing.
    public static func later(_ f: @escaping () -> A) -> Trampoline<A> {
        .defer { .done(f()) }
    }
    
    /// Executes the computations described by this Trampoline by converting it into a loop.
    ///
    /// - Returns: Value resulting from the execution of the Trampoline.
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
    
    /// Composes this trampoline with another one that depends on the output of this one.
    ///
    /// - Parameter f: Function to compute a Trampoline based on the value of this one.
    /// - Returns: A Trampoline describing the sequential application of both.
    public func flatMap<B>(_ f: @escaping (A) -> Trampoline<B>) -> Trampoline<B> {
        FlatMap(self, f)
    }
    
    /// Transforms the eventual value provided by this Trampoline.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A Trampoline that behaves as the original one but its result is transformed.
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
