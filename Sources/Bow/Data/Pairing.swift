// type Pairing f g = forall a b. f (a -> b) -> g a -> b

public final class ForPairing {}
public final class PairingPartial<F: Functor>: Kind<ForPairing, F> {}
public typealias PairingOf<F: Functor, G: Functor> =  Kind<PairingPartial<F>, G>

public class Pairing<F: Functor, G: Functor>: PairingOf<F, G> {
    internal let pairing: (Kind<F, /*A*/Any>,
                           Kind<G, /*B*/Any>,
                           @escaping (/*A*/Any, /*B*/Any) -> /*C*/Any) -> /*C*/Any
    
    
    public static func fix(_ value: PairingOf<F, G>) -> Pairing<F, G> {
        value as! Pairing<F, G>
    }
    
    public init(_ zap: @escaping (Kind<F, (/*A*/Any) -> /*B*/Any>, Kind<G, /*A*/Any>) -> /*B*/Any) {
        self.pairing = { fa, gb, fab in zap(fa.map(curry(fab)), gb) }
    }
    
    public init(_ pairing: @escaping (Kind<F, /*A*/Any>, Kind<G, /*B*/Any>, @escaping (/*A*/Any, /*B*/Any) -> /*C*/Any) -> /*C*/Any) {
        self.pairing = pairing
    }
    
    /// Annihilate the `F` and `G` effects effectively calling the wrapped function in `F` with the wrapped value
    ///
    /// - Parameter fab: An `F`-effectful `A -> B`
    /// - Parameter ga: A `G`-effectful `A`
    /// - Returns: A pure `B`
    public func zap<A, B>(_ fab: Kind<F, (A) -> B>, _ ga: Kind<G, A>) -> B {
        pair(fab, ga) { f, a in f(a) }
    }
    
    public func pair<A, B, C>(_ fa: Kind<F, A>, _ gb: Kind<G, B>, _ f: @escaping (A, B) -> C) -> C {
        pairing(fa.map { a in a as Any },
                gb.map { b in b as Any }) { a, b in f(a as! A, b as! B) } as! C
    }
    
    public func select<A, B>(_ fa: Kind<F, A>, _ ggb: Kind<G, Kind<G, B>>) -> Kind<G, B> {
        pair(fa, ggb) { _, gb in gb }
    }
    
    public func pairFlipped<A, B, C>(_ ga: Kind<G, A>, _ fb: Kind<F, B>, _ f: @escaping (A, B) -> C) -> C {
        pair(fb, ga, flip(f))
    }
    
    public func pairStateTStoreT<S>() -> Pairing<StateTPartial<F, S>, StoreTPartial<S, G>> {
        Pairing<StateTPartial<F, S>, StoreTPartial<S, G>>.pairStateTStoreT(self)
    }
    
    public func pairWriterTTracedT<W>() -> Pairing<WriterTPartial<F, W>, TracedTPartial<W, G>> {
        Pairing<WriterTPartial<F, W>, TracedTPartial<W, G>>.pairWriterTTracedT(self)
    }
    
    public func pairReaderTEnvT<R>() -> Pairing<ReaderTPartial<F, R>, EnvTPartial<R, G>> {
        Pairing<ReaderTPartial<F, R>, EnvTPartial<R, G>>.pairReaderTEnvT(self)
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Pairing.
public postfix func ^<F, G>(_ value: PairingOf<F, G>) -> Pairing<F, G> {
    Pairing.fix(value)
}

// MARK: Pairing for Id

public extension Pairing where F == ForId, G == ForId {
    static func pairId() -> Pairing<ForId, ForId> {
        Pairing { fa, gb in
            fa^.value(gb^.value)
        }
    }
}

// MARK: Pairing for State and Store

public extension Pairing {
    static func pairStateTStoreT<S, FF, GG>(_ pairing: Pairing<FF, GG>) -> Pairing<StateTPartial<FF, S>, StoreTPartial<S, GG>> where F == StateTPartial<FF, S>, G == StoreTPartial<S, GG> {
        Pairing { state, store, f in
            pairing.pair(state^.runM(store^.state), store^.render) { a, b in
                f(a.1, b(a.0))
            }
        }
    }
    
    static func pairStateStore<S>() -> Pairing<StatePartial<S>, StorePartial<S>> where F == StatePartial<S>, G == StorePartial<S> {
        .pairStateTStoreT(.pairId())
    }
}

// MARK: Pairing for Writer and Traced

public extension Pairing {
    static func pairWriterTTracedT<W, FF, GG>(_ pairing: Pairing<FF, GG>) -> Pairing<WriterTPartial<FF, W>, TracedTPartial<W, GG>> where F == WriterTPartial<FF, W>, G == TracedTPartial<W, GG> {
        Pairing { writer, traced, f in
            pairing.pair(writer^.runT, traced^.value) { a, b in f(a.1, b(a.0)) }
        }
    }
    
    static func pairWriterTraced<W>() -> Pairing<WriterPartial<W>, TracedPartial<W>> where F == WriterPartial<W>, G == TracedPartial<W> {
        .pairWriterTTracedT(.pairId())
    }
}

// MARK: Pairing for Reader and Env

public extension Pairing {
    static func pairReaderTEnvT<R, FF, GG>(_ pairing: Pairing<FF, GG>) -> Pairing<ReaderTPartial<FF, R>, EnvTPartial<R, GG>> where F == ReaderTPartial<FF, R>, G == EnvTPartial<R, GG> {
        Pairing { reader, env, f in
            pairing.pair(reader^.run(env^.runT().0), env^.runT().1, f)
        }
    }
    
    static func pairReaderEnv<R>() -> Pairing<ReaderPartial<R>, EnvPartial<R>> where F == ReaderPartial<R>, G == EnvPartial<R> {
        .pairReaderTEnvT(.pairId())
    }
}

// MARK: Pairing for any Comonad

public extension Comonad {
    static func pair() -> Pairing<Self, CoPartial<Self>> {
        Pairing { wab, cowa in cowa^.run(wab) }
    }
}

public extension Kind where F: Comonad {
    static func pair() -> Pairing<F, CoPartial<F>> {
        F.pair()
    }
}
