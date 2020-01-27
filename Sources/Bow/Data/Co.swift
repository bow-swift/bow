// newtype CoT w m a = Co (forall r. w (a -> m r) -> m r)

public final class ForCoT {}
public final class CoTPartial<W: Comonad, M>: Kind2<ForCoT, W, M> {}
public typealias CoTOf<W: Comonad, M, A> = Kind<CoTPartial<W, M>, A>

public typealias ForCo = ForCoT
public typealias CoPartial<W: Comonad> = CoTPartial<W, ForId>
public typealias CoOf<W: Comonad, A> = CoTOf<W, ForId, A>
public typealias Co<W: Comonad, A> = CoT<W, ForId, A>

public typealias Transition<W: Comonad, A> = Co<W, A>
public typealias TransitionT<W: Comonad, M, A> = CoT<W, M, A>

/// (CoT w) gives you "the best" pairing monad transformer for any comonad w
/// In other words, an explorer for the state space given by w
public class CoT<W: Comonad, M, A>: CoTOf<W, M, A> {
    internal let cow: (Kind<W, (A) -> Kind<M, Any>>) -> Kind<M, Any>
    
    public static func fix(_ value: CoTOf<W, M, A>) -> CoT<W, M, A> {
        value as! CoT<W, M, A>
    }
    
    public static func liftT(_ f: @escaping (Kind<W, Any/*S*/>) -> A) -> CoT<W, M, A> {
        let extract = Function1<Kind<W, (Any) -> Kind<M, Any>>, (Any) -> Kind<M, Any>> { x in x.extract() }
        let ff = Function1<Kind<W, (Any) -> Kind<M, Any>>, A> { x in f(x.map { xx in xx as Any }) }.map { a in a as Any }
        let g: (Any) -> A = { a in a as! A }
        let adapt: (Kind<W, (A) -> Kind<M, Any>>) -> Kind<W, (Any) -> Kind<M, Any>> = { wf in
            wf.map { f in g >>> f }
        }
        let ap: (Kind<W, (Any) -> Kind<M, Any>>) -> Kind<M, Any> = extract.ap(ff)^.f
        
        return CoT(adapt >>> ap)
    }
    
    public init(_ cow: @escaping /*forall R.*/(Kind<W, (A) -> Kind<M, /*R*/Any>>) -> Kind<M, /*R*/Any>) {
        self.cow = cow
    }
    
    func runT<R>(_ w: Kind<W, (A) -> Kind<M, R>>) -> Kind<M, R> {
        unsafeBitCast(self.cow, to:((Kind<W, (A) -> Kind<M, R>>) -> Kind<M, R>).self)(w)
    }
    
    func hoistT<V: Comonad>(_ transform: FunctionK<V, W>) -> CoT<V, M, A> {
        CoT<V, M, A>(self.cow <<< transform.invoke)
    }
}

public extension CoT where M: Applicative {
    func lowerT<B>(_ input: Kind<W, B>) -> Kind<M, A> {
        (self.runT <<< { wbma in wbma.as(M.pure) })(input)
    }
}

public extension CoT where M == ForId {
    static func select<A, B>(_ co: Co<W, (A) -> B>, _ wa: Kind<W, A>) -> Kind<W, B> {
        co.run(wa.coflatMap { wa in
            { f in wa.map(f) }
        })
    }
    
    static func lift(_ f: @escaping (Kind<W, Any>) -> A) -> Co<W, A> {
        liftT(f)
    }
    
    /// - Returns: The pairing between the underlying comonad, `w`, and the monad `Co<w>`.
    static func pair() -> Pairing<W, CoPartial<W>> {
        Pairing { wab, cowa in cowa^.run(wab) }
    }
    
    func run<R>(_ w: Kind<W, (A) -> R>) -> R {
        self.runT(w.map { f in f >>> Id.pure })^.value
    }
    
    func hoist<V>(_ transform: FunctionK<V, W>) -> Co<V, A> {
        Co<V, A>(self.cow <<< transform.invoke)
    }
    
    func lower<B>(_ input: Kind<W, B>) -> A {
        lowerT(input)^.value
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Co.
public postfix func ^<W, M, A>(_ value: CoTOf<W, M, A>) -> CoT<W, M, A> {
    CoT.fix(value)
}

// MARK: Instance of `Functor` for `Co`

extension CoTPartial: Functor {
    public static func map<A, B>(_ fa: CoTOf<W, M, A>, _ f: @escaping (A) -> B) -> CoTOf<W, M, B> {
        CoT<W, M, B> { b in
            fa^.runT(b.map { bb in bb <<< f })
        }
    }
}

// MARK: Instance of `Applicative` for `Co`

extension CoTPartial: Applicative {
    public static func ap<A, B>(_ ff: CoTOf<W, M, (A) -> B>, _ fa: CoTOf<W, M, A>) -> CoTOf<W, M, B> {
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

// MARK: Instance of `Monad` for `Co`

extension CoTPartial: Monad {
    public static func flatMap<A, B>(_ fa: CoTOf<W, M, A>, _ f: @escaping (A) -> CoTOf<W, M, B>) -> CoTOf<W, M, B> {
        CoT { w in
            fa^.cow(w.coflatMap { wa in
                { a in
                    f(a)^.runT(wa)
                }
            })
        }
    }
    
    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> CoTOf<W, M, Either<A, B>>) -> CoTOf<W, M, B> {
        f(a).flatMap { either in
            either.fold(
                { aa in tailRecM(aa, f) },
                { b in CoT.pure(b) })
        }
    }
}
