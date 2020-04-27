// newtype CoT w m a = Co (forall r. w (a -> m r) -> m r)

/// Witness for the `CoT<W, M, A>` data type. To be used in simulated Higher Kinded Types
public final class ForCoT {}

/// Partial application of the CoT type constructor, omitting the last parameter.
public final class CoTPartial<W: Comonad, M>: Kind2<ForCoT, W, M> {}

/// Higher Kinded Type alias to improve readability of `Kind<CoTPartial<W, M>, A>`.
public typealias CoTOf<W: Comonad, M, A> = Kind<CoTPartial<W, M>, A>

/// Witness for the `Co<W, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForCo = ForCoT

/// Partial application of the Co type constructor, omitting the last parameter.
public typealias CoPartial<W: Comonad> = CoTPartial<W, ForId>

/// Higher Kinded Type alias to improve readability of `Kind<CoPartial<W>, A>`.
public typealias CoOf<W: Comonad, A> = CoTOf<W, ForId, A>

/// Co is equivalent to CoT where the base monad is Id.
public typealias Co<W: Comonad, A> = CoT<W, ForId, A>

/// Alias for Co.
public typealias Transition<W: Comonad, A> = Co<W, A>

/// Alias for CoT.
public typealias TransitionT<W: Comonad, M, A> = CoT<W, M, A>

/// CoT gives you "the best" pairing monad transformer for any Comonad W
/// In other words, an explorer for the state space given by W. It can also provide:
///     - A MonadReader from a ComonadEnv
///     - A MonadWriter from a ComonadTraced
///     - A MonadState from a ComonadStore
public class CoT<W: Comonad, M, A>: CoTOf<W, M, A> {
    internal let cow: (Kind<W, (A) -> Kind<M, Any>>) -> Kind<M, Any>
    
    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to CoT.
    public static func fix(_ value: CoTOf<W, M, A>) -> CoT<W, M, A> {
        value as! CoT<W, M, A>
    }
    
    /// Lifts a comonadic query into a CoT.
    ///
    /// The original signature of this function is:
    ///     `(forall s. w s -> a) -> CoT w m a`
    ///
    /// - Parameter f: Comonadic query.
    /// - Returns: A CoT from the Comonadic query.
    public static func liftT(_ f: @escaping (Kind<W, Any/*S*/>) -> A) -> CoT<W, M, A> {
        // This implementation is equivalent to:
        // CoT(extract <*> f)
        
        let extract = Function1<Kind<W, (Any) -> Kind<M, Any>>, (Any) -> Kind<M, Any>> { x in x.extract() }
        let ff = Function1<Kind<W, (Any) -> Kind<M, Any>>, A> { x in f(x.map { xx in xx as Any }) }.map { a in a as Any }
        let g: (Any) -> A = { a in a as! A }
        let adapt: (Kind<W, (A) -> Kind<M, Any>>) -> Kind<W, (Any) -> Kind<M, Any>> = { wf in
            wf.map { f in g >>> f }
        }
        let ap: (Kind<W, (Any) -> Kind<M, Any>>) -> Kind<M, Any> = extract.ap(ff)^.f
        
        return CoT(adapt >>> ap)
    }
    
    /// Initializes a CoT. It embeds a function with the signature:
    ///     `forall r. w (a -> m r) -> m r`
    ///
    /// - Parameter cow: Inner function of this CoT.
    public init(_ cow: @escaping /*forall R.*/(Kind<W, (A) -> Kind<M, /*R*/Any>>) -> Kind<M, /*R*/Any>) {
        self.cow = cow
    }
    
    /// Runs the inner function.
    ///
    /// - Parameter w: Argument for the inner function.
    /// - Returns: Value in the base Monad context.
    public func runT<R>(_ w: Kind<W, (A) -> Kind<M, R>>) -> Kind<M, R> {
        unsafeBitCast(self.cow, to:((Kind<W, (A) -> Kind<M, R>>) -> Kind<M, R>).self)(w)
    }
    
    /// Performs a natural transformation on the Comonad of this CoT.
    ///
    /// - Parameters:
    ///     - transform: Natural transformation.
    /// - Returns: A new CoT with the transformed Comonad.
    public func hoistT<V: Comonad>(_ transform: FunctionK<V, W>) -> CoT<V, M, A> {
        CoT<V, M, A>(self.cow <<< transform.invoke)
    }
}

public extension CoT where M: Applicative {
    /// Runs the inner function with a value that does not runs on the base Monad.
    ///
    /// - Parameter input: A value in the Comonad context.
    /// - Returns: A value in the base Monad context.
    func lowerT<B>(_ input: Kind<W, B>) -> Kind<M, A> {
        (self.runT <<< { wbma in wbma.as(M.pure) })(input)
    }
}

public extension CoT where M == ForId {
    /// Explores the space of a Comonad with a given Monad.
    ///
    /// - Parameters:
    ///   - co: Monadic actions to explore the Comonad.
    ///   - wa: Comonadic space to explore.
    /// - Returns: A new Comonadic space resulting from the exploration.
    static func select<A, B>(
        _ co: Co<W, (A) -> B>,
        _ wa: Kind<W, A>) -> Kind<W, B> {
        co.run(wa.coflatMap { wa in
            { f in wa.map(f) }
        })
    }
    
    /// Lifts a comonadic query into a CoT.
    ///
    /// The original signature of this function is:
    ///     `(forall s. w s -> a) -> Co w a`
    ///
    /// - Parameter f: Comonadic query.
    /// - Returns: A Co from the Comonadic query.
    static func lift(_ f: @escaping (Kind<W, Any>) -> A) -> Co<W, A> {
        liftT(f)
    }
    
    /// Obtains a Pairing between a Comonad and its dual Monad.
    ///
    /// - Returns: The pairing between the underlying comonad, W, and the monad `Co<w>`.
    static func pair() -> Pairing<W, CoPartial<W>> {
        Pairing { wab, cowa in cowa^.run(wab) }
    }
    
    /// Runs the inner function.
    ///
    /// - Parameter w: Argument for the inner function.
    /// - Returns: A plain value.
    func run<R>(_ w: Kind<W, (A) -> R>) -> R {
        self.runT(w.map { f in f >>> Id.pure })^.value
    }
    
    /// Performs a natural transformation on the Comonad of this Co.
    ///
    /// - Parameters:
    ///     - transform: Natural transformation.
    /// - Returns: A new Co with the transformed Comonad.
    func hoist<V: Comonad>(_ transform: FunctionK<V, W>) -> Co<V, A> {
        Co<V, A>(self.cow <<< transform.invoke)
    }
    
    /// Runs the inner function with a value that does not runs on the base Monad.
    ///
    /// - Parameter input: A value in the Comonad context.
    /// - Returns: A plain value.
    func lower<B>(_ input: Kind<W, B>) -> A {
        lowerT(input)^.value
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to CoT.
public postfix func ^<W, M, A>(_ value: CoTOf<W, M, A>) -> CoT<W, M, A> {
    CoT.fix(value)
}

// MARK: Instance of Functor for CoT

extension CoTPartial: Functor {
    public static func map<A, B>(
        _ fa: CoTOf<W, M, A>,
        _ f: @escaping (A) -> B) -> CoTOf<W, M, B> {
        CoT<W, M, B> { b in
            fa^.runT(b.map { bb in bb <<< f })
        }
    }
}

// MARK: Instance of Applicative for CoT

extension CoTPartial: Applicative {
    public static func ap<A, B>(
        _ ff: CoTOf<W, M, (A) -> B>,
        _ fa: CoTOf<W, M, A>) -> CoTOf<W, M, B> {
        CoT<W, M, B> { w in
            ff^.cow(w.coflatMap { wf in
                { g in
                    fa^.cow(wf.map { ff in ff <<< g})
                }
            })
        }
    }
    
    public static func pure<A>(_ a: A) -> CoTOf<W, M, A> {
        CoT<W, M, A> { w in w.extract()(a) }
    }
}

// MARK: Instance of Monad for CoT

extension CoTPartial: Monad {
    public static func flatMap<A, B>(
        _ fa: CoTOf<W, M, A>,
        _ f: @escaping (A) -> CoTOf<W, M, B>) -> CoTOf<W, M, B> {
        CoT { w in
            fa^.cow(w.coflatMap { wa in
                { a in
                    f(a)^.runT(wa)
                }
            })
        }
    }
    
    public static func tailRecM<A, B>(
        _ a: A,
        _ f: @escaping (A) -> CoTOf<W, M, Either<A, B>>) -> CoTOf<W, M, B> {
        f(a).flatMap { either in
            either.fold(
                { aa in tailRecM(aa, f) },
                { b in CoT.pure(b) })
        }
    }
}

// MARK: Instance of MonadReader for CoT

extension CoTPartial: MonadReader where W: ComonadEnv {
    public typealias D = W.E
    
    public static func ask() -> CoTOf<W, M, W.E> {
        CoT.liftT(W.ask)
    }
    
    public static func local<A>(
        _ fa: CoTOf<W, M, A>,
        _ f: @escaping (W.E) -> W.E) -> CoTOf<W, M, A> {
        CoT(fa^.cow <<< { wa in wa.local(f) })
    }
}

// MARK: Instance of MonadState for CoT

extension CoTPartial: MonadState where W: ComonadStore {
    public typealias S = W.S
    
    public static func get() -> CoTOf<W, M, W.S> {
        CoT.liftT { wa in wa.position }
    }
    
    public static func set(_ s: W.S) -> CoTOf<W, M, ()> {
        CoT { wa in wa.peek(s)(()) }
    }
}

// MARK: Instance of MonadWriter for CoT

extension CoTPartial: MonadWriter where W: ComonadTraced {
    public typealias W = W.M
    
    public static func writer<A>(_ aw: (W.M, A)) -> CoTOf<W, M, A> {
        CoT { wa in wa.trace(aw.0)(aw.1) }
    }
    
    public static func listen<A>(_ fa: CoTOf<W, M, A>) -> CoTOf<W, M, (W.M, A)> {
        func f<A>(_ x: W.M, _ g: @escaping ((W.M, A)) -> Kind<M, Any>) -> (A) -> Kind<M, Any> {
            { a in
                g((x, a))
            }
        }
        
        return CoT { wa in
            let listened = wa.listen().map(f)
            return fa^.runT(listened)
        }
    }
    
    public static func pass<A>(_ fa: CoTOf<W, M, ((W.M) -> W.M, A)>) -> CoTOf<W, M, A> {
        CoT { wa in
            let passed: Kind<W, (((W.M) -> W.M, A)) -> Kind<M, Any>> = wa.pass().map { f in { tuple in f(tuple.0)(tuple.1) } }
            return fa^.runT(passed)
        }
    }
}
