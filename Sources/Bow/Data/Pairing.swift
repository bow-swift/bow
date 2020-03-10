// type Pairing f g = forall a b. f (a -> b) -> g a -> b

/// Witness for the `Pairing<F, G>` data type. To be used in simulated Higher Kinded Types.
public final class ForPairing {}

/// Partial application of the Pairing type constructor, omitting the last parameter.
public final class PairingPartial<F: Functor>: Kind<ForPairing, F> {}

/// Higher Kinded Type alias to improve readability of `Kind<PairingPartial<F>, G>`.
public typealias PairingOf<F: Functor, G: Functor> = Kind<PairingPartial<F>, G>

/// The Pairing type represents a relationship between Functors F and G, where the sums in one can annihilate the products in the other.
///
/// The internals of this type embed a function of the following shape:
///     `forall a b c. f a -> g b -> (a -> b -> c) -> c`
/// Or equivalently:
///     `forall a b. f (a -> b) -> g a -> b`
///
/// Swift lacks universal quantifiers, so these types are replaced by `Any`.
public class Pairing<F: Functor, G: Functor>: PairingOf<F, G> {
    internal let pairing: (Kind<F, /*A*/Any>,
                           Kind<G, /*B*/Any>,
                           @escaping (/*A*/Any, /*B*/Any) -> /*C*/Any) -> /*C*/Any
    
    
    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to Pairing.
    public static func fix(_ value: PairingOf<F, G>) -> Pairing<F, G> {
        value as! Pairing<F, G>
    }
    
    /// Initializes a Pairing.
    ///
    /// - Parameter zap: Relationship between the Functors, captured as a function of the form: `forall a b. f (a -> b) -> g a -> b`
    public init(_ zap: @escaping (Kind<F, (/*A*/Any) -> /*B*/Any>, Kind<G, /*A*/Any>) -> /*B*/Any) {
        self.pairing = { fa, gb, fab in zap(fa.map(curry(fab)), gb) }
    }
    
    /// Initializes a Pairing.
    ///
    /// - Parameter pairing: Relationship between the Functors, captured as a function of the form: `forall a b c. f a -> g b -> (a -> b -> c) -> c`
    public init(_ pairing: @escaping (Kind<F, /*A*/Any>, Kind<G, /*B*/Any>, @escaping (/*A*/Any, /*B*/Any) -> /*C*/Any) -> /*C*/Any) {
        self.pairing = pairing
    }
    
    /// Annihilate the `F` and `G` effects by calling the wrapped function in `F` with the wrapped value
    ///
    /// - Parameter fab: An `F`-effectful `A -> B`
    /// - Parameter ga: A `G`-effectful `A`
    /// - Returns: A pure `B`
    public func zap<A, B>(_ fab: Kind<F, (A) -> B>, _ ga: Kind<G, A>) -> B {
        pair(fab, ga) { f, a in f(a) }
    }
    
    /// Annilate the `F` and `G` effects by extracting the values in their contexts and using the combination function.
    ///
    /// - Parameters:
    ///   - fa: An F-effectful value.
    ///   - gb: A G-effectful value.
    ///   - f: A function to combine the values in both contexts.
    /// - Returns: Result of annihilating both effectful values and combining them with the provided function.
    public func pair<A, B, C>(_ fa: Kind<F, A>, _ gb: Kind<G, B>, _ f: @escaping (A, B) -> C) -> C {
        pairing(fa.map { a in a as Any },
                gb.map { b in b as Any }) { a, b in f(a as! A, b as! B) } as! C
    }
    
    /// Explores the space given by one Functor, using the other as an explorer.
    ///
    /// - Parameters:
    ///   - fa: Explorer Functorial value.
    ///   - ggb: Spact Functorial value.
    /// - Returns: Result of the exploration.
    public func select<A, B>(_ fa: Kind<F, A>, _ ggb: Kind<G, Kind<G, B>>) -> Kind<G, B> {
        pair(fa, ggb) { _, gb in gb }
    }
    
    /// Annihilates the F and G effectful values with arguments flipped.
    ///
    /// - Parameters:
    ///   - ga: A G-effectful value.
    ///   - fb: An F-effectful value.
    ///   - f: Combination function.
    /// - Returns: Result of annihilating both effectful values and combining them with the provided function.
    public func pairFlipped<A, B, C>(_ ga: Kind<G, A>, _ fb: Kind<F, B>, _ f: @escaping (A, B) -> C) -> C {
        pair(fb, ga, flip(f))
    }
    
    /// Lifts this Pairing to use it for a StateT-StoreT pairing.
    ///
    /// - Returns: A pairing for StateT-StoreT where their base Monad and Comonad are paired with this pairing.
    public func pairStateTStoreT<S>() -> Pairing<StateTPartial<F, S>, StoreTPartial<S, G>> {
        Pairing<StateTPartial<F, S>, StoreTPartial<S, G>>.pairStateTStoreT(self)
    }
    
    /// Lifts this Pairing to use it for a WriterT-TracedT pairing.
    ///
    /// - Returns: A pairing for WriterT-TracedT where their base Monad and Comonad are paired with this pairing.
    public func pairWriterTTracedT<W>() -> Pairing<WriterTPartial<F, W>, TracedTPartial<W, G>> {
        Pairing<WriterTPartial<F, W>, TracedTPartial<W, G>>.pairWriterTTracedT(self)
    }
    
    /// Lifts this Pairing to use it for a ReaderT-EnvT pairing.
    ///
    /// - Returns: A pairing for ReaderT-EnvT where their base Monad and Comonad are paired with this pairing.
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
    /// Provides a Pairing for Id-Id.
    ///
    /// - Returns: A Pairing for Id-Id.
    static func pairId() -> Pairing<ForId, ForId> {
        Pairing { fa, gb in
            fa^.value(gb^.value)
        }
    }
}

// MARK: Pairing for State and Store

public extension Pairing {
    /// Provides a Pairing for StateT-StoreT.
    ///
    /// - Parameter pairing: Pairing for the base Monad and Comonad in StateT-StoreT.
    /// - Returns: A Pairing for StateT-StoreT using the provided Pairing to annihilate their internal base Monad and Comonad.
    static func pairStateTStoreT<S, FF, GG>(_ pairing: Pairing<FF, GG>) -> Pairing<StateTPartial<FF, S>, StoreTPartial<S, GG>> where F == StateTPartial<FF, S>, G == StoreTPartial<S, GG> {
        Pairing { state, store, f in
            pairing.pair(state^.runM(store^.state), store^.render) { a, b in
                f(a.1, b(a.0))
            }
        }
    }
    
    /// Provides a Pairing for State-Store.
    ///
    /// - Returns: A Pairing for State-Store.
    static func pairStateStore<S>() -> Pairing<StatePartial<S>, StorePartial<S>> where F == StatePartial<S>, G == StorePartial<S> {
        .pairStateTStoreT(.pairId())
    }
}

// MARK: Pairing for Writer and Traced

public extension Pairing {
    /// Provides a Pairing for WriterT-TracedT.
    ///
    /// - Parameter pairing: Pairing for the base Monad and Comonad in WriterT-TracedT.
    /// - Returns: A Pairing for WriterT-TracedT using the provided Pairing to annihilate their internal base Monad and Comonad.
    static func pairWriterTTracedT<W, FF, GG>(_ pairing: Pairing<FF, GG>) -> Pairing<WriterTPartial<FF, W>, TracedTPartial<W, GG>> where F == WriterTPartial<FF, W>, G == TracedTPartial<W, GG> {
        Pairing { writer, traced, f in
            pairing.pair(writer^.runT, traced^.value) { a, b in f(a.1, b(a.0)) }
        }
    }
    
    /// Provides a Pairing for Writer-Traced.
    ///
    /// - Returns: A Pairing for Writer-Traced.
    static func pairWriterTraced<W>() -> Pairing<WriterPartial<W>, TracedPartial<W>> where F == WriterPartial<W>, G == TracedPartial<W> {
        .pairWriterTTracedT(.pairId())
    }
}

// MARK: Pairing for Reader and Env

public extension Pairing {
    /// Provides a Pairing for ReaderT-EnvT.
    ///
    /// - Parameter pairing: Pairing for the base Monad and Comonad in ReaderT-EnvT.
    /// - Returns: A Pairing for ReaderT-EnvT using the provided Pairing to annihilate their internal base Monad and Comonad.
    static func pairReaderTEnvT<R, FF, GG>(_ pairing: Pairing<FF, GG>) -> Pairing<ReaderTPartial<FF, R>, EnvTPartial<R, GG>> where F == ReaderTPartial<FF, R>, G == EnvTPartial<R, GG> {
        Pairing { reader, env, f in
            pairing.pair(reader^.run(env^.runT().0), env^.runT().1, f)
        }
    }
    
    /// Provides a Pairing for Reader-Env.
    ///
    /// - Returns: A Pairing for Reader-Env.
    static func pairReaderEnv<R>() -> Pairing<ReaderPartial<R>, EnvPartial<R>> where F == ReaderPartial<R>, G == EnvPartial<R> {
        .pairReaderTEnvT(.pairId())
    }
}

// MARK: Pairing for Action and Moore

public extension Pairing {
    /// Provides a Pairing for Action-Moore.
    ///
    /// - Returns: A Pairing for Action-Moore.
    static func pairActionMoore<I>() -> Pairing<ActionPartial<I>, MoorePartial<I>> where F == ActionPartial<I>, G == MoorePartial<I> {
        Pairing { action, moore, f in
            MoorePartial<I>.pair().pairFlipped(action, moore, f)
        }
    }
}

// MARK: Pairing for CoSum and Sum

public extension Pairing {
    /// Provides a Pairing for CoSum-Sum.
    ///
    /// - Returns: A Pairing for CoSum-Sum.
    static func pairCoSumSum<FF, GG>() -> Pairing<CoSumPartial<FF, GG>, SumPartial<FF, GG>> where F == CoSumPartial<FF, GG>, G == SumPartial<FF, GG> {
        Pairing { cosum, sum, f in
            SumPartial<FF, GG>.pair().pairFlipped(cosum, sum, f)
        }
    }
}

// MARK: Pairing for CoSumOpt and SumOpt

public extension Pairing {
    /// Provides a Pairing for CoSumOpt-SumOpt.
    ///
    /// - Returns: A Pairing for CoSumOpt-SumOpt.
    static func pairCoSumOptSumOpt<FF>() -> Pairing<CoSumOptPartial<FF>, SumOptPartial<FF>> where F == CoSumOptPartial<FF>, G == SumOptPartial<FF> {
        Pairing { cosumopt, sumopt, f in
            SumOptPartial<FF>.pair().pairFlipped(cosumopt, sumopt, f)
        }
    }
}

// MARK: Pairing for Puller and Zipper

public extension Pairing where F == ForPuller, G == ForZipper {
    /// Provides a Pairing for Puller-Zipper.
    ///
    /// - Returns: A Pairing for Puller-Zipper.
    static func pairPullerZipper() -> Pairing<ForPuller, ForZipper> {
        Pairing { puller, zipper, f in
            ForZipper.pair().pairFlipped(puller, zipper, f)
        }
    }
}

// MARK: Pairing for any Comonad

public extension Comonad {
    /// Provides a Pairing for this Comonad and its dual Monad.
    ///
    /// - Returns: A Pairing for this Comonad and its dual Monad.
    static func pair() -> Pairing<Self, CoPartial<Self>> {
        Pairing { wab, cowa in cowa^.run(wab) }
    }
}

// MARK: Syntax for Pairing

public extension Kind where F: Comonad {
    /// Provides a Pairing for this Comonad and its dual Monad.
    ///
    /// - Returns: A Pairing for this Comonad and its dual Monad.
    static func pair() -> Pairing<F, CoPartial<F>> {
        F.pair()
    }
}
