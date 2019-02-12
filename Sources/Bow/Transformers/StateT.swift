import Foundation

public final class ForStateT {}
public final class StateTPartial<F, S>: Kind2<ForStateT, F, S> {}
public typealias StateTOf<F, S, A> = Kind<StateTPartial<F, S>, A>

public class StateT<F, S, A>: StateTOf<F, S, A> {
    fileprivate let runF: Kind<F, (S) -> Kind<F, (S, A)>>
    
    public static func fix(_ fa : StateTOf<F, S, A>) -> StateT<F, S, A> {
        return fa as! StateT<F, S, A>
    }

    public init(_ runF : Kind<F, (S) -> Kind<F, (S,A)>>) {
        self.runF = runF
    }
}

public extension StateT where F == ForId {
    public func run(_ initialState: S) -> (S, A) {
        return Id.fix(self.runM(initialState)).value
    }
    
    public func runA(_ s: S) -> A {
        return run(s).1
    }
    
    public func runS(_ s: S) -> S {
        return run(s).0
    }
}

extension StateT where F: Functor {
    public func transform<B>(_ f : @escaping (S, A) -> (S, B)) -> StateT<F, S, B> {
        return StateT<F, S, B>(
            runF.map { sfsa in
                sfsa >>> F.lift(f)
            }
        )
    }
}

extension StateT where F: Monad {
    public static func lift(_ fa: Kind<F, A>) -> StateT<F, S, A> {
        return StateT(F.pure({ s in fa.map { a in (s, a) } }))
    }

    public func runA(_ s: S) -> Kind<F, A> {
        return runM(s).map{ (_, a) in a }
    }

    public func runS(_ s: S) -> Kind<F, S> {
        return runM(s).map { (s, _) in s }
    }

    public func runM(_ initial: S) -> Kind<F, (S, A)> {
        return runF.flatMap { f in f(initial) }
    }

    public func map2<B, Z>(_ sb: StateT<F, S, B>, _ f: @escaping (A, B) -> Z) -> StateT<F, S, Z> {
        return StateT<F, S, Z>(F.map(runF, sb.runF, { ssa, ssb in
            ssa >>> { fsa in
                F.flatMap(fsa) { (s, a) in
                    F.map(ssb(s), { (s, b) in (s, f(a, b)) })
                }
            }
        }))
    }

    public func flatMapF<B>(_ f : @escaping (A) -> Kind<F, B>) -> StateT<F, S, B> {
        return StateT<F, S, B>(
            runF.map { sfsa in
                sfsa >>> { fsa in
                    fsa.flatMap { (s, a) in
                        f(a).map { b in (s, b) }
                    }
                }
            }
        )
    }
}

extension StateTPartial: Invariant where F: Functor {}

extension StateTPartial: Functor where F: Functor {
    public static func map<A, B>(_ fa: Kind<StateTPartial<F, S>, A>, _ f: @escaping (A) -> B) -> Kind<StateTPartial<F, S>, B> {
        return StateT.fix(fa).transform({ (s, a) in (s, f(a)) })
    }
}

extension StateTPartial: Applicative where F: Monad {
    public static func pure<A>(_ a: A) -> Kind<StateTPartial<F, S>, A> {
        return StateT(F.pure({ s in F.pure((s, a)) }))
    }
}

extension StateTPartial: Monad where F: Monad {
    public static func flatMap<A, B>(_ fa: Kind<StateTPartial<F, S>, A>, _ f: @escaping (A) -> Kind<StateTPartial<F, S>, B>) -> Kind<StateTPartial<F, S>, B> {
        let sta = StateT.fix(fa)
        return StateT<F, S, B>(
            sta.runF.map { sfsa in
                sfsa >>> { fsa in
                    fsa.flatMap { (s, a) in
                        StateT.fix(f(a)).runM(s)
                    }
                }
            }
        )
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<StateTPartial<F, S>, Either<A, B>>) -> Kind<StateTPartial<F, S>, B> {
        return StateT<F, S, B>(F.pure({ s in
            F.tailRecM((s, a), { pair in
                F.map(StateT.fix(f(pair.1)).runM(pair.0), { sss, ab in
                    ab.bimap({ left in (sss, left) }, { right in (sss, right) })
                })
            })
        }))
    }
}

extension StateTPartial: MonadState where F: Monad {
    public static func get() -> Kind<StateTPartial<F, S>, S> {
        return StateT(F.pure({ s in F.pure((s, s)) }))
    }

    public static func set(_ s: S) -> Kind<StateTPartial<F, S>, ()> {
        return StateT(F.pure({ _ in F.pure((s, ())) } ))
    }
}

extension StateTPartial: SemigroupK where F: Monad & SemigroupK {
    public static func combineK<A>(_ x: Kind<StateTPartial<F, S>, A>, _ y: Kind<StateTPartial<F, S>, A>) -> Kind<StateTPartial<F, S>, A> {
        let stx = StateT.fix(x)
        let sty = StateT.fix(y)
        return StateT(F.pure({ s in stx.runM(s).combineK(sty.runM(s)) }))
    }
}

extension StateTPartial: MonoidK where F: MonadCombine {
    public static func emptyK<A>() -> Kind<StateTPartial<F, S>, A> {
        return StateT.lift(F.empty())
    }
}

extension StateTPartial: Alternative where F: MonadCombine {}

extension StateTPartial: FunctorFilter where F: MonadCombine {}

extension StateTPartial: MonadFilter where F: MonadCombine {}

extension StateTPartial: MonadCombine where F: MonadCombine {
    public static func empty<A>() -> Kind<StateTPartial<F, S>, A> {
        return StateT.lift(F.empty())
    }
}

extension StateTPartial: ApplicativeError where F: MonadError {
    public typealias E = F.E

    public static func raiseError<A>(_ e: F.E) -> Kind<StateTPartial<F, S>, A> {
        return StateT.lift(F.raiseError(e))
    }

    public static func handleErrorWith<A>(_ fa: Kind<StateTPartial<F, S>, A>, _ f: @escaping (F.E) -> Kind<StateTPartial<F, S>, A>) -> Kind<StateTPartial<F, S>, A> {
        return StateT(F.pure({ s in
            StateT.fix(fa).runM(s).handleErrorWith { e in
                StateT.fix(f(e)).runM(s)
            }
        }))
    }
}

extension StateTPartial: MonadError where F: MonadError {}
