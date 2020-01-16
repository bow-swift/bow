// type Pairing f g = forall a b. f (a -> b) -> g a -> b

public final class ForPairing {}
public final class PairingPartial<F: Functor>: Kind<ForPairing, F> {}
public typealias PairingOf<F: Functor, G: Functor> =  Kind<PairingPartial<F>, G>

public class Pairing<F: Functor, G: Functor>: PairingOf<F, G> {
    // internal let pair: (Kind<F, (/*A*/Any) -> /*B*/Any>, Kind<G, /*A*/Any>) -> /*B*/Any
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
    
    public func pairFlipped<A, B, C>(_ ga: Kind<G, A>, _ fb: Kind<F, B>, _ f: @escaping (A, B) -> C) -> C {
        pair(fb, ga, flip(f))
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

// MARK: Pairing for Writer and Traced

public extension Pairing {
    static func pairWriterTTracedT<W, FF, GG>(_ pairing: Pairing<FF, GG>) -> Pairing<WriterTPartial<FF, W>, TracedTPartial<W, GG>> where F == WriterTPartial<FF, W>, G == TracedTPartial<W, GG> {
        Pairing { writer, traced, f in
            pairing.pair(writer^.runT, traced^.value) { a, b in f(a.1, b(a.0)) }
        }
    }
    
    static func pairWriterTraced<W>() -> Pairing<WriterPartial<W>, TracedPartial<W>> where F == WriterPartial<W>, G == TracedPartial<W> {
        Pairing.pairWriterTTracedT(.pairId())
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
        Pairing.pairReaderTEnvT(.pairId())
    }
}
