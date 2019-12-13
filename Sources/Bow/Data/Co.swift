// newtype Co w a = Co (forall r. w (a -> r) -> r)

final class ForCo {}
final class CoPartial<W: Comonad>: Kind<ForCo, W> {}
typealias CoOf<W: Comonad, A> = Kind<CoPartial<W>, A>

/// (Co w) gives you "the best" pairing monad for any comonad w
/// In other words, an explorer for the state space given by w
class Co<W: Comonad, A> : CoOf<W, A> {
    internal let cow : (Kind<W, (A) -> Any>) -> Any
    
    static func fix(_ value : CoOf<W, A>) -> Co<W, A> {
        value as! Co<W, A>
    }
    
    /// - Returns: The pairing between the underlying comonad, `w`, and the monad `Co<w>`.
    static func pair() -> Pairing<W, CoPartial<W>> {
        Pairing{ wab in
            { cowa in
                Co<W, /*A*/Any>.fix(cowa).runCo(wab)
            }
        }
    }
    
    init(_ cow: @escaping /*forall R.*/(Kind<W, (A) -> /*R*/Any>) -> /*R*/Any) {
        self.cow = cow
    }
    
    func runCo<R>(_ w: Kind<W, (A) -> R>) -> R {
        unsafeBitCast(self.cow, to:((Kind<W, (A) -> R>) -> R).self) (w)
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Co.
postfix func ^<W, A>(_ value: CoOf<W, A>) -> Co<W, A> {
    return Co.fix(value)
}

extension CoPartial: Functor {
    static func map<A, B>(_ fa: CoOf<W, A>, _ f: @escaping (A) -> B) -> CoOf<W, B> {
        Co<W, B> { b in
            Co<W, A>.fix(fa).runCo(b.map({$0 <<< f}))
        }
    }
}

extension CoPartial: Applicative {
    static func ap<A, B>(_ ff: CoOf<W, (A) -> B>, _ fa: CoOf<W, A>) -> CoOf<W, B> {
        let f = Co<W, (A) -> B>.fix(ff).cow
        let a = Co<W, A>.fix(fa).cow
        return Co<W, B> { w in
            f(
                w.coflatMap{ wf in
                    { g in
                        a(wf.map{$0 <<< g})
                    }
                }
            )
        }
    }
    
    static func pure<A>(_ a: A) -> CoOf<W, A> {
        return Co<W, A> { w in
            w.extract()(a)
        }
    }
}

extension CoPartial: Monad {
    static func flatMap<A, B>(_ fa: CoOf<W, A>, _ f: @escaping (A) -> CoOf<W, B>) -> CoOf<W, B> {
        let k: (Kind<W, (A) -> Any>) -> Any = Co<W, A>.fix(fa).cow
        return Co<W, B> { w in
            k (
                w.coflatMap{ wa in
                    { a in
                        Co<W, B>.fix(f(a)).runCo(wa)
                    }
                }
            )
        }
    }
    
    static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<CoPartial<W>, Either<A, B>>) -> Kind<CoPartial<W>, B> {
        // TODO: Please help
        fatalError("TODO")
    }
}

extension Co {
    // I don't remember what this function does, but including it for reference.
    static func select<A, B>(
        co : Co<W, (A) -> B>,
        wa : Kind<W, A>
        ) -> Kind<W, B> {
        return co.runCo(wa.coflatMap{ wa in { f in
            wa.map(f)
            }
        })
    }
}
