public final class ForEnvT {}
public final class EnvTPartial<E, W>: Kind2<ForEnvT, E, W> {}
public typealias EnvTOf<E, W, A> = Kind<EnvTPartial<E, W>, A>

public typealias ForEnv = ForEnvT
public typealias EnvPartial<E> = EnvTPartial<E, ForId>
public typealias EnvOf<E, A> = EnvTOf<E, ForId, A>
public typealias Env<E, A> = EnvT<E, ForId, A>

public final class EnvT<E, W, A>: EnvTOf<E, W, A> {
    fileprivate let e: E
    fileprivate let wa: Kind<W, A>
    
    public static func fix(_ value: EnvTOf<E, W, A>) -> EnvT<E, W, A> {
        value as! EnvT<E, W, A>
    }
    
    public init(_ e: E, _ wa: Kind<W, A>) {
        self.e = e
        self.wa = wa
    }
    
    public init(_ pair: (E, Kind<W, A>)) {
        self.e = pair.0
        self.wa = pair.1
    }
    
    public func runT() -> (E, Kind<W, A>) {
        (e, wa)
    }
    
    public func local<EE>(_ f: @escaping (E) -> EE) -> EnvT<EE, W, A> {
        EnvT<EE, W, A>(f(e), wa)
    }
}

public postfix func ^<E, W, A>(_ value: EnvTOf<E, W, A>) -> EnvT<E, W, A> {
    EnvT.fix(value)
}

// MARK: Syntax for Env

public extension EnvT where W == ForId {
    convenience init(_ e: E, _ a: A) {
        self.init(e, Id(a))
    }
    
    func run() -> (E, A) {
        let (e, wa) = runT()
        return (e, wa^.value)
    }
}

// MARK: Instance of `Invariant` for `EnvT`

extension EnvTPartial: Invariant where W: Functor {}

// MARK: Instance of `Functor` for `EnvT`

extension EnvTPartial: Functor where W: Functor {
    public static func map<A, B>(_ fa: EnvTOf<E, W, A>, _ f: @escaping (A) -> B) -> EnvTOf<E, W, B> {
        EnvT(fa^.e, fa^.wa.map(f))
    }
}

// MARK: Instance of `Applicative` for `EnvT`

extension EnvTPartial: Applicative where W: Applicative, E: Monoid {
    public static func pure<A>(_ a: A) -> Kind<EnvTPartial<E, W>, A> {
        EnvT(E.empty(), W.pure(a))
    }
    
    public static func ap<A, B>(_ ff: EnvTOf<E, W, (A) -> B>, _ fa: EnvTOf<E, W, A>) -> EnvTOf<E, W, B> {
        EnvT(ff^.e.combine(fa^.e), ff^.wa.ap(fa^.wa))
    }
}

// MARK: Instance of `Comonad` for `EnvT`

extension EnvTPartial: Comonad where W: Comonad {
    public static func coflatMap<A, B>(_ fa: EnvTOf<E, W, A>, _ f: @escaping (EnvTOf<E, W, A>) -> B) -> EnvTOf<E, W, B> {
        EnvT(fa^.e, fa^.wa.coflatMap { a in f(EnvT(fa^.e, a)) })
    }
    
    public static func extract<A>(_ fa: EnvTOf<E, W, A>) -> A {
        fa^.wa.extract()
    }
}

// MARK: Instance of `ComonadEnv` for `EnvT`

extension EnvTPartial: ComonadEnv where W: Comonad {
    public static func ask<A>(_ wa: EnvTOf<E, W, A>) -> E {
        wa^.e
    }
    
    public static func local<A>(_ wa: EnvTOf<E, W, A>, _ f: @escaping (E) -> E) -> EnvTOf<E, W, A> {
        EnvT(f(wa^.e), wa^.wa)
    }
}

// MARK: Instance of `Foldable` for `EnvT`

extension EnvTPartial: Foldable where W: Foldable {
    public static func foldLeft<A, B>(_ fa: EnvTOf<E, W, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        fa^.wa.foldLeft(b, f)
    }
    
    public static func foldRight<A, B>(_ fa: EnvTOf<E, W, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        fa^.wa.foldRight(b, f)
    }
}

// MARK: Instance of `Traverse` for `EnvT`

extension EnvTPartial: Traverse where W: Traverse, E: Monoid {
    public static func traverse<G: Applicative, A, B>(_ fa: EnvTOf<E, W, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, EnvTOf<E, W, B>> {
        fa^.wa.traverse(f).map { x in EnvT(fa^.e, x) }
    }
}
