// newtype Co w a = Co (forall r. w (a -> r) -> r)

public final class ForCo {}
public final class CoPartial<W: Comonad>: Kind<ForCo, W> {}
public typealias CoOf<W: Comonad, A> = Kind<CoPartial<W>, A>

/// (Co w) gives you "the best" pairing monad for any comonad w
/// In other words, an explorer for the state space given by w
public class Co<W: Comonad, A>: CoOf<W, A> {
    internal let cow: (Kind<W, (A) -> Any>) -> Any
    
    public static func fix(_ value: CoOf<W, A>) -> Co<W, A> {
        value as! Co<W, A>
    }
    
    public static func select<A, B>(_ co: Co<W, (A) -> B>, _ wa: Kind<W, A>) -> Kind<W, B> {
        co.run(wa.coflatMap { wa in
            { f in wa.map(f) }
        })
    }
    
    public init(_ cow: @escaping /*forall R.*/(Kind<W, (A) -> /*R*/Any>) -> /*R*/Any) {
        self.cow = cow
    }
    
    func run<R>(_ w: Kind<W, (A) -> R>) -> R {
        unsafeBitCast(self.cow, to:((Kind<W, (A) -> R>) -> R).self)(w)
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Co.
public postfix func ^<W, A>(_ value: CoOf<W, A>) -> Co<W, A> {
    Co.fix(value)
}

extension CoPartial: Functor {
    public static func map<A, B>(_ fa: CoOf<W, A>, _ f: @escaping (A) -> B) -> CoOf<W, B> {
        Co<W, B> { b in
            fa^.run(b.map { bb in bb <<< f })
        }
    }
}

extension CoPartial: Applicative {
    public static func ap<A, B>(_ ff: CoOf<W, (A) -> B>, _ fa: CoOf<W, A>) -> CoOf<W, B> {
        Co<W, B> { w in
            ff^.cow(w.coflatMap { wf in
                { g in
                    fa^.cow(wf.map { ff in ff <<< g})
                }
            })
        }
    }
    
    public static func pure<A>(_ a: A) -> CoOf<W, A> {
        Co<W, A> { w in w.extract()(a) }
    }
}

extension CoPartial: Monad {
    public static func flatMap<A, B>(_ fa: CoOf<W, A>, _ f: @escaping (A) -> CoOf<W, B>) -> CoOf<W, B> {
        Co { w in
            fa^.cow(w.coflatMap { wa in
                { a in
                    Co<W, B>.fix(f(a)).run(wa)
                }
            })
        }
    }
    
    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> CoOf<W, Either<A, B>>) -> CoOf<W, B> {
        f(a).flatMap { either in
            either.fold(
                { aa in tailRecM(aa, f) },
                { b in Co.pure(b) })
        }
    }
}
