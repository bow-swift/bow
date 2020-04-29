/// Witness for the `TracedT<M, W, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForTracedT {}

/// Partial application of the `TracedT` type constructor, omitting the last parameter.
public final class TracedTPartial<M, W>: Kind2<ForTracedT, M, W> {}

/// Higher Kinded Type alias to improve readability of `Kind<TracedTPartial<M, W>, A>`.
public typealias TracedTOf<M, W, A> = Kind<TracedTPartial<M, W>, A>

/// Witness for the `Traced<M, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForTraced = ForTracedT

/// Partial application of the `Traced` type constructor, omitting the last parameter.
public typealias TracedPartial<M> = TracedTPartial<M, ForId>

/// Higher Kinded Type alias to improve readability of `Kind<TracedPartial<M>, A>`.
public typealias TracedOf<M, A> = TracedTOf<M, ForId, A>

/// The Traced type is equivalent to the TracedT type, with the base comonad being Id.
public typealias Traced<M, A> = TracedT<M, ForId, A>

/// The cowriter Comonad Transformer. This Comonad Transformer extends the context of a value in the base Comonad so that the value depends on a monoidal position.
public final class TracedT<M, W, A>: TracedTOf<M, W, A> {
    /// Function to access values relative to a monoidal position, in the context of the base Comonad.
    public let value: Kind<W, (M) -> A>
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to TracedT.
    public static func fix(_ fa: TracedTOf<M, W, A>) -> TracedT<M, W, A> {
        fa as! TracedT<M, W, A>
    }
    
    /// Initializes a TracedT value.
    ///
    /// - Parameter value: Function in the context of the base Comonad.
    public init(_ value: Kind<W, (M) -> A>) {
        self.value = value
    }
}

extension TracedT where M: Monoid, W: Functor {
    /// Obtains the comonadic value without the Traced support.
    ///
    /// - Returns: Comonadic value without Traced support.
    public func lower() -> Kind<W, A> {
        value.map { f in f(M.empty()) }
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in the higher-kind form.
/// - Returns: Value cast to TracedT.
public postfix func ^<M, W, A>(_ value: TracedTOf<M, W, A>) -> TracedT<M, W, A> {
    TracedT.fix(value)
}

// MARK: Syntax for Traced

extension TracedT where W == ForId {
    /// Initializes a Traced value.
    ///
    /// - Parameter f: Function to access values from a monoidal position.
    public convenience init(_ f: @escaping (M) -> A) {
        self.init(Id(f))
    }
    
    /// Invokes this function.
    ///
    /// - Parameter input: Input to the function.
    /// - Returns: Output of the function.
    public func callAsFunction(_ input: M) -> A {
        self.value^.value(input)
    }
}

// MARK: Instance of Invariant for TracedT

extension TracedTPartial: Invariant where W: Functor {}

// MARK: Instance of Functor for TracedT

extension TracedTPartial: Functor where W: Functor {
    public static func map<A, B>(
        _ fa: TracedTOf<M, W, A>,
        _ f: @escaping (A) -> B) -> TracedTOf<M, W, B> {
        TracedT(fa^.value.map { ff in ff >>> f })
    }
}

// MARK: Instance of Applicative for TracedT

extension TracedTPartial: Applicative where W: Applicative {
    public static func pure<A>(_ a: A) -> TracedTOf<M, W, A> {
        TracedT(W.pure(constant(a)))
    }
    
    public static func ap<A, B>(
        _ ff: TracedTOf<M, W, (A) -> B>,
        _ fa: TracedTOf<M, W, A>) -> TracedTOf<M, W, B> {
        TracedT(W.map(ff^.value, fa^.value) { vf, va in
            { m in vf(m)(va(m))}
        })
    }
}

// MARK: Instance of Comonad for TracedT

extension TracedTPartial: Comonad where W: Comonad, M: Monoid {
    public static func coflatMap<A, B>(
        _ fa: TracedTOf<M, W, A>,
        _ f: @escaping (TracedTOf<M, W, A>) -> B) -> TracedTOf<M, W, B> {
        TracedT(fa^.value.coflatMap { wma in
            { m in
                f(TracedT(wma.map { ma in
                    curry(M.combine)(m) >>> ma
                }))
            }
        })
    }
    
    public static func extract<A>(_ fa: TracedTOf<M, W, A>) -> A {
        fa^.value.extract()(M.empty())
    }
}

// MARK: Instance of ComonadTraced for TracedT

extension TracedTPartial: ComonadTraced where W: Comonad, M: Monoid {
    public static func trace<A>(
        _ wa: TracedTOf<M, W, A>,
        _ m: M) -> A {
        wa^.value.extract()(m)
    }

    public static func listens<A, B>(
        _ wa: TracedTOf<M, W, A>,
        _ f: @escaping (M) -> B) -> TracedTOf<M, W, (B, A)> {
        TracedT(wa^.value.map { g in
            { m in (f(m), g(m)) }
        })
    }
    
    public static func pass<A>(_ wa: TracedTOf<M, W, A>) -> TracedTOf<M, W, ((M) -> M) -> A> {
        TracedT(wa^.value.map { trace in
            { m in
                { f in
                    trace(f(m))
                }
            }
        })
    }
}

// MARK: Instance of ComonadStore for TracedT

extension TracedTPartial: ComonadStore where W: ComonadStore, M: Monoid {
    public typealias S = W.S
    
    public static func position<A>(_ wa: TracedTOf<M, W, A>) -> W.S {
        wa^.lower().position
    }
    
    public static func peek<A>(
        _ wa: TracedTOf<M, W, A>,
        _ s: W.S) -> A {
        wa^.lower().peek(s)
    }
}

// MARK: Instance of ComonadEnv for TracedT

extension TracedTPartial: ComonadEnv where W: ComonadEnv, M: Monoid {
    public typealias E = W.E
    
    public static func ask<A>(_ wa: TracedTOf<M, W, A>) -> W.E {
        wa^.lower().ask()
    }
    
    public static func local<A>(
        _ wa: TracedTOf<M, W, A>,
        _ f: @escaping (W.E) -> W.E) -> TracedTOf<M, W, A> {
        TracedT(wa^.value.local(f))
    }
}
