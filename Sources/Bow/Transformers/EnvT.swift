/// Witness for the `EnvT<E, W, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForEnvT {}

/// Partial application of the `EnvT` type constructor, omitting the last parameter.
public final class EnvTPartial<E, W>: Kind2<ForEnvT, E, W> {}

/// Higher Kinded Type alias to improve readability of `Kind<EnvTPartial<E, W>, A>`.
public typealias EnvTOf<E, W, A> = Kind<EnvTPartial<E, W>, A>

/// Witness for the `Env<E, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForEnv = ForEnvT

/// Partial application of the `Env` type constructor, omitting the last parameter.
public typealias EnvPartial<E> = EnvTPartial<E, ForId>

/// Higher Kinded Type alias to improve readability of `Kind<EnvPartial<E>, A>`.
public typealias EnvOf<E, A> = EnvTOf<E, ForId, A>

/// The Env type is equivalent to the EnvT type, with the base comonad being Id.
public typealias Env<E, A> = EnvT<E, ForId, A>

/// The environment Comonad Transformer. This Comonad Transformer extends the context of a value in the base Comonad with a global environment.
public final class EnvT<E, W, A>: EnvTOf<E, W, A> {
    fileprivate let e: E
    fileprivate let wa: Kind<W, A>
    
    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to EnvT.
    public static func fix(_ value: EnvTOf<E, W, A>) -> EnvT<E, W, A> {
        value as! EnvT<E, W, A>
    }
    
    /// Initializes an EnvT with an environment and a value of the base Comonad.
    ///
    /// - Parameters:
    ///   - e: Environment.
    ///   - wa: Value of the base comonad.
    public init(_ e: E, _ wa: Kind<W, A>) {
        self.e = e
        self.wa = wa
    }
    
    /// Initializes an EnvT with a pair containing an environment and a value of the base Comonad.
    ///
    /// - Parameter pair: Tuple with the environment and a value of the base Comonad.
    public init(_ pair: (E, Kind<W, A>)) {
        self.e = pair.0
        self.wa = pair.1
    }
    
    /// Obtains a tuple with the environment and a value of the base Comonad.
    ///
    /// - Returns: A tuple with the environment and a value of the base Comonad.
    public func runT() -> (E, Kind<W, A>) {
        (e, wa)
    }
    
    /// Changes the type of the environment.
    ///
    /// - Parameter f: Function to transform the current environment.
    public func local<EE>(_ f: @escaping (E) -> EE) -> EnvT<EE, W, A> {
        EnvT<EE, W, A>(f(e), wa)
    }
    
    /// Obtains the wrapped comonadic value without the environment.
    ///
    /// - Returns: Wrapped comonadic value without the environment.
    public func lower() -> Kind<W, A> {
        wa
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in the higher-kind form.
/// - Returns: Value cast to EnvT.
public postfix func ^<E, W, A>(_ value: EnvTOf<E, W, A>) -> EnvT<E, W, A> {
    EnvT.fix(value)
}

// MARK: Syntax for Env

public extension EnvT where W == ForId {
    /// Initializes an Env with an environment and a value.
    /// - Parameters:
    ///   - e: Environment.
    ///   - a: Value in the base Comonad.
    convenience init(_ e: E, _ a: A) {
        self.init(e, Id(a))
    }
    
    /// Obtains a tuple with the environment and the wrapped value.
    ///
    /// - Returns: A tuple with the environment and the wrapped value.
    func run() -> (E, A) {
        let (e, wa) = runT()
        return (e, wa^.value)
    }
}

// MARK: Instance of Invariant for EnvT

extension EnvTPartial: Invariant where W: Functor {}

// MARK: Instance of Functor for EnvT

extension EnvTPartial: Functor where W: Functor {
    public static func map<A, B>(_ fa: EnvTOf<E, W, A>, _ f: @escaping (A) -> B) -> EnvTOf<E, W, B> {
        EnvT(fa^.e, fa^.wa.map(f))
    }
}

// MARK: Instance of Applicative for EnvT

extension EnvTPartial: Applicative where W: Applicative, E: Monoid {
    public static func pure<A>(_ a: A) -> EnvTOf<E, W, A> {
        EnvT(E.empty(), W.pure(a))
    }
    
    public static func ap<A, B>(
        _ ff: EnvTOf<E, W, (A) -> B>,
        _ fa: EnvTOf<E, W, A>) -> EnvTOf<E, W, B> {
        EnvT(ff^.e.combine(fa^.e), ff^.wa.ap(fa^.wa))
    }
}

// MARK: Instance of Comonad for EnvT

extension EnvTPartial: Comonad where W: Comonad {
    public static func coflatMap<A, B>(
        _ fa: EnvTOf<E, W, A>,
        _ f: @escaping (EnvTOf<E, W, A>) -> B) -> EnvTOf<E, W, B> {
        EnvT(fa^.e, fa^.wa.coflatMap { a in f(EnvT(fa^.e, a)) })
    }
    
    public static func extract<A>(_ fa: EnvTOf<E, W, A>) -> A {
        fa^.wa.extract()
    }
}

// MARK: Instance of ComonadEnv for EnvT

extension EnvTPartial: ComonadEnv where W: Comonad {
    public static func ask<A>(_ wa: EnvTOf<E, W, A>) -> E {
        wa^.e
    }
    
    public static func local<A>(
        _ wa: EnvTOf<E, W, A>,
        _ f: @escaping (E) -> E) -> EnvTOf<E, W, A> {
        EnvT(f(wa^.e), wa^.wa)
    }
}

// MARK: Instance of Foldable for EnvT

extension EnvTPartial: Foldable where W: Foldable {
    public static func foldLeft<A, B>(
        _ fa: EnvTOf<E, W, A>,
        _ b: B,
        _ f: @escaping (B, A) -> B) -> B {
        fa^.wa.foldLeft(b, f)
    }
    
    public static func foldRight<A, B>(
        _ fa: EnvTOf<E, W, A>,
        _ b: Eval<B>,
        _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        fa^.wa.foldRight(b, f)
    }
}

// MARK: Instance of Traverse for EnvT

extension EnvTPartial: Traverse where W: Traverse, E: Monoid {
    public static func traverse<G: Applicative, A, B>(
        _ fa: EnvTOf<E, W, A>,
        _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, EnvTOf<E, W, B>> {
        fa^.wa.traverse(f).map { x in EnvT(fa^.e, x) }
    }
}

// MARK: Instance of ComonadStore for EnvT

extension EnvTPartial: ComonadStore where W: ComonadStore {
    public typealias S = W.S
    
    public static func position<A>(_ wa: EnvTOf<E, W, A>) -> W.S {
        wa^.lower().position
    }
    
    public static func peek<A>(
        _ wa: EnvTOf<E, W, A>,
        _ s: W.S) -> A {
        wa^.lower().peek(s)
    }
}

// MARK: Instance of ComonadTraced for EnvT

extension EnvTPartial: ComonadTraced where W: ComonadTraced {
    public typealias M = W.M
    
    public static func trace<A>(
        _ wa: EnvTOf<E, W, A>,
        _ m: W.M) -> A {
        wa^.lower().trace(m)
    }
    
    public static func listens<A, B>(
        _ wa: EnvTOf<E, W, A>,
        _ f: @escaping (W.M) -> B) -> EnvTOf<E, W, (B, A)> {
        EnvT(wa^.e, wa^.lower().listens(f))
    }
    
    public static func pass<A>(_ wa: EnvTOf<E, W, A>) -> EnvTOf<E, W, ((W.M) -> W.M) -> A> {
        EnvT(wa^.e, wa^.lower().pass())
    }
}
