/// Witness for the `Trampoline<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForTrampoline {}

/// Partial application of the Trampoline type constructor, omitting the last type parameter.
public typealias TrampolinePartial = ForTrampoline

/// Higher Kinded Type alias to improve readability over `Kind<ForTrampoline, A>`
public typealias TrampolineOf<A> = Kind<ForTrampoline, A>

/// The Trampoline type helps us overcome stack safety issues of recursive calls by transforming them into loops.
public final class Trampoline<A>: TrampolineOf<A> {
    fileprivate init(_ value: _Trampoline<A>) {
        self.value = value
    }

    fileprivate let value: _Trampoline<A>
    /// Creates a Trampoline that does not need to recurse and provides the final result.
    ///
    /// - Parameter value: Result of the computation.
    /// - Returns: A Trampoline that provides a value and stops recursing.
    public static func done(_ value: A) -> Trampoline<A> {
        Trampoline(.done(value))
    }
    
    /// Creates a Trampoline that performs a computation and needs to recurse.
    ///
    /// - Parameter f: Function describing the recursive step.
    /// - Returns: A Trampoline that describes a recursive step.
    public static func `defer`(_ f: @escaping () -> Trampoline<A>) -> Trampoline<A> {
        Trampoline(.defer(f))
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
        value.step()
    }
    
    /// Composes this trampoline with another one that depends on the output of this one.
    ///
    /// - Parameter f: Function to compute a Trampoline based on the value of this one.
    /// - Returns: A Trampoline describing the sequential application of both.
    public func flatMap<B>(_ f: @escaping (A) -> Trampoline<B>) -> Trampoline<B> {
        Trampoline<B>(.flatMap(Coyoneda(pivot: self, f: f)))
    }
    
    /// Transforms the eventual value provided by this Trampoline.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A Trampoline that behaves as the original one but its result is transformed.
    public func map<B>(_ f: @escaping (A) -> B) -> Trampoline<B> {
        flatMap { a in .done(f(a)) }
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Trampoline.
    public static func fix(_ fa: TrampolineOf<A>) -> Trampoline<A> {
        fa as! Trampoline<A>
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Trampoline.
public postfix func ^<A>(_ fa: TrampolineOf<A>) -> Trampoline<A> {
    Trampoline.fix(fa)
}

private enum _Trampoline<A> {
    case done(A)
    case `defer`(() -> Trampoline<A>)
    case flatMap(Coyoneda<ForTrampoline, Trampoline<A>>)

    func step() -> Either<() -> Trampoline<A>, A> {
        switch self {
        case .done(let a):
            return .right(a)
        case .defer(let deferred):
            return .left(deferred)
        case .flatMap(let coyoneda):
            return coyoneda.coyonedaF.run(FlatMapStep())
        }
    }

    public func flatMap<B>(_ f: @escaping (A) -> Trampoline<B>) -> Trampoline<B> {
        switch self {
        case .done, .defer:
            return Trampoline(.flatMap(Coyoneda(pivot: Trampoline(self), f: f)))
        case .flatMap(let coyoneda):
            return coyoneda.coyonedaF.run(FlatMapFlatMap(f))
        }
    }
}

private final class FlatMapStep<A>: CokleisliK<CoyonedaFPartial<ForTrampoline, Trampoline<A>>, Either<() -> Trampoline<A>, A>> {
    override init() {}

    override func invoke<X>(_ fa: Kind<CoyonedaFPartial<ForTrampoline, Trampoline<A>>, X>) -> Either<() -> Trampoline<A>, A> {
        let pivot = fa^.pivot^
        let f = fa^.f

        switch pivot.value {
        case .done(let x):
            return .left { [f] in
                f(x)
            }
        case .defer(let deferred):
            return .left { [f] in
                deferred().flatMap(f)
            }
        default:
            fatalError("Invalid Trampoline case")
        }
    }
}

private final class FlatMapFlatMap<A, B>: CokleisliK<CoyonedaFPartial<ForTrampoline, Trampoline<A>>, Trampoline<B>> {
    init(_ g: @escaping (A) -> Trampoline<B>) {
        self.g = g
    }

    let g: (A) -> Trampoline<B>

    override func invoke<X>(_ fa: Kind<CoyonedaFPartial<ForTrampoline, Trampoline<A>>, X>) -> Trampoline<B> {
        let pivot = fa^.pivot^
        let f = fa^.f
        return Trampoline(
            .flatMap(
                Coyoneda(
                    pivot: pivot,
                    f: { [g] a in f(a).flatMap(g) })
            )
        )
    }
}
