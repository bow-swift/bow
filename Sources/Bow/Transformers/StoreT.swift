public final class ForStoreT {}
public final class StoreTPartial<S, W>: Kind2<ForStoreT, S, W> {}
public typealias StoreTOf<S, W, A> = Kind<StoreTPartial<S, W>, A>

public final class StoreT<S, W, A>: StoreTOf<S, W, A> {
    public let render: Kind<W, (S) -> A>
    public let state: S
    
    public static func fix(_ value: StoreTOf<S, W, A>)-> StoreT<S, W, A> {
        value as! StoreT<S, W, A>
    }
    
    public init(_ state: S, _ render: Kind<W, (S) -> A>) {
        self.state = state
        self.render = render
    }
}

public extension StoreT where W: Comonad {
    func move(_ newState: S) -> StoreT<S, W, A> {
        self.duplicate()^.peek(newState)^
    }
}

public postfix func ^<S, W, A>(_ value: StoreTOf<S, W, A>) -> StoreT<S, W, A> {
    StoreT.fix(value)
}

// MARK: Instance of `Invariant` for `StoreT`

extension StoreTPartial: Invariant where W: Functor {}

// MARK: Instance of `Functor` for `StoreT`

extension StoreTPartial: Functor where W: Functor {
    public static func map<A, B>(_ fa: StoreTOf<S, W, A>, _ f: @escaping (A) -> B) -> StoreTOf<S, W, B> {
        StoreT(fa^.state, fa^.render.map { ff in ff >>> f })
    }
}

// MARK: Instance of `Applicative` for `StoreT`

extension StoreTPartial: Applicative where W: Applicative, S: Monoid {
    public static func pure<A>(_ a: A) -> StoreTOf<S, W, A> {
        StoreT(S.empty(), W.pure(constant(a)))
    }
    
    public static func ap<A, B>(_ ff: StoreTOf<S, W, (A) -> B>, _ fa: StoreTOf<S, W, A>) -> StoreTOf<S, W, B> {
        StoreT(ff^.state.combine(fa^.state),
               W.map(ff^.render, fa^.render) { rf, ra in { s in rf(s)(ra(s)) } })
    }
}

// MARK: Instance of `Comonad` for `StoreT`

extension StoreTPartial: Comonad where W: Comonad {
    public static func coflatMap<A, B>(_ fa: StoreTOf<S, W, A>, _ f: @escaping (StoreTOf<S, W, A>) -> B) -> StoreTOf<S, W, B> {
        StoreT(fa^.state,
               fa^.render.coflatMap { wa in { s in f(StoreT(s, wa)) } })
    }
    
    public static func extract<A>(_ fa: StoreTOf<S, W, A>) -> A {
        fa^.render.extract()(fa^.state)
    }
}

// MARK: Instance of `ComonadStore` for `StoreT`

extension StoreTPartial: ComonadStore where W: Comonad {
    public static func position<A>(_ wa: StoreTOf<S, W, A>) -> S {
        wa^.state
    }
    
    public static func peek<A>(_ wa: StoreTOf<S, W, A>, _ s: S) -> A {
        wa^.render.extract()(s)
    }
}
