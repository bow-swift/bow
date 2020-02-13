public final class ForTracedT {}
public final class TracedTPartial<M, W>: Kind2<ForTracedT, M, W> {}
public typealias TracedTOf<M, W, A> = Kind<TracedTPartial<M, W>, A>

public typealias ForTraced = ForTracedT
public typealias TracedPartial<M> = TracedTPartial<M, ForId>
public typealias Traced<M, A> = TracedT<M, ForId, A>

public final class TracedT<M, W, A>: TracedTOf<M, W, A> {
    public let value: Kind<W, (M) -> A>
    
    public static func fix(_ fa: TracedTOf<M, W, A>) -> TracedT<M, W, A> {
        fa as! TracedT<M, W, A>
    }
    
    public init(_ value: Kind<W, (M) -> A>) {
        self.value = value
    }
}

public postfix func ^<M, W, A>(_ value: TracedTOf<M, W, A>) -> TracedT<M, W, A> {
    TracedT.fix(value)
}

// MARK: Syntax for Traced

extension TracedT where W == ForId {
    public convenience init(_ f: @escaping (M) -> A) {
        self.init(Id(f))
    }
}

// MARK: Instance of `Invariant` for `TracedT`

extension TracedTPartial: Invariant where W: Functor {}

// MARK: Instance of `Functor` for `TracedT`

extension TracedTPartial: Functor where W: Functor {
    public static func map<A, B>(_ fa: TracedTOf<M, W, A>, _ f: @escaping (A) -> B) -> TracedTOf<M, W, B> {
        TracedT(fa^.value.map { ff in ff >>> f })
    }
}

// MARK: Instance of `Applicative` for `TracedT`

extension TracedTPartial: Applicative where W: Applicative {
    public static func pure<A>(_ a: A) -> TracedTOf<M, W, A> {
        TracedT(W.pure(constant(a)))
    }
    
    public static func ap<A, B>(_ ff: TracedTOf<M, W, (A) -> B>, _ fa: TracedTOf<M, W, A>) -> TracedTOf<M, W, B> {
        TracedT(W.map(ff^.value, fa^.value) { vf, va in
            { m in vf(m)(va(m))}
        })
    }
}

// MARK: Instance of `Comonad` for `TracedT`

extension TracedTPartial: Comonad where W: Comonad, M: Monoid {
    public static func coflatMap<A, B>(_ fa: TracedTOf<M, W, A>, _ f: @escaping (TracedTOf<M, W, A>) -> B) -> TracedTOf<M, W, B> {
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

// MARK: Instance of `ComonadTraced` for `TracedT`

extension TracedTPartial: ComonadTraced where W: Comonad, M: Monoid {
    public static func trace<A>(_ wa: TracedTOf<M, W, A>, _ m: M) -> A {
        wa^.value.extract()(m)
    }

    public static func listens<A, B>(_ wa: TracedTOf<M, W, A>, _ f: @escaping (M) -> B) -> TracedTOf<M, W, (B, A)> {
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
