import Foundation

public class ForStateT {}
public typealias StateTOf<F, S, A> = Kind3<ForStateT, F, S, A>
public typealias StateTPartial<F, S> = Kind2<ForStateT, F, S>

public class StateT<F, S, A> : StateTOf<F, S, A> {
    private let runF : Kind<F, (S) -> Kind<F, (S,A)>>
    
    public static func lift<Mon>(_ fa : Kind<F, A>, _ monad : Mon) -> StateT<F, S, A> where Mon : Monad, Mon.F == F {
        return StateT(monad.pure({ s in monad.map(fa, { a in (s, a) }) }))
    }
    
    public static func get<Appl>(_ applicative : Appl) -> StateT<F, S, S> where Appl : Applicative, Appl.F == F {
        return StateT<F, S, S>(applicative.pure({ s in applicative.pure((s, s)) }))
    }
    
    public static func set<Appl>(_ s : S, _ applicative : Appl) -> StateT<F, S, ()> where Appl : Applicative, Appl.F == F {
        return StateT<F, S, ()>(applicative.pure({ _ in applicative.pure((s, ())) }))
    }
    
    public static func tailRecM<B, Mon>(_ a : A, _ f : @escaping (A) -> Kind<StateTPartial<F, S>, Either<A, B>>, _ monad : Mon) -> StateT<F, S, B> where Mon : Monad, Mon.F == F {
        return StateT<F, S, B>(monad.pure({ s in
            monad.tailRecM((s, a), { pair in
                monad.map(StateT<F, S, Either<A, B>>.fix(f(pair.1)).runM(pair.0, monad), { sss, ab in
                    ab.bimap({ left in (sss, left) }, { right in (sss, right) })
                })
            })
        }))
    }
    
    public static func fix(_ fa : StateTOf<F, S, A>) -> StateT<F, S, A> {
        return fa as! StateT<F, S, A>
    }
    
    public init(_ runF : Kind<F, (S) -> Kind<F, (S,A)>>) {
        self.runF = runF
    }
    
    public func transform<B, Func>(_ f : @escaping (S, A) -> (S, B), _ functor : Func) -> StateT<F, S, B> where Func : Functor, Func.F == F {
        return StateT<F, S, B>(
            functor.map(runF, { sfsa in
                sfsa >>> { fsa in functor.map(fsa, f) }
            })
        )
    }
    
    public func map<B, Func>(_ f : @escaping (A) -> B, _ functor : Func) -> StateT<F, S, B> where Func : Functor, Func.F == F {
        return transform({ (s, a) in (s, f(a)) }, functor)
    }
    
    public func map2<B, Z, Mon>(_ sb : StateT<F, S, B>, _ f : @escaping (A, B) -> Z, _ monad : Mon) -> StateT<F, S, Z> where Mon : Monad, Mon.F == F {
        return StateT<F, S, Z>(monad.map2(runF, sb.runF, { ssa, ssb in
            ssa >>> { fsa in
                monad.flatMap(fsa) { (s, a) in
                    monad.map(ssb(s), { (s, b) in (s, f(a, b)) })
                }
            }
        }))
    }
    
    public func map2Eval<B, Z, Mon>(_ esb : Eval<StateT<F, S, B>>, _ f : @escaping (A, B) -> Z, _ monad : Mon) -> Eval<StateT<F, S, Z>> where Mon : Monad, Mon.F == F {
        return monad.map2Eval(runF, esb.map{ sb in sb.runF }){ ssa, ssb in
            ssa >>> { fsa in
                monad.flatMap(fsa) { (s, a) in
                    monad.map(ssb(s)) { (s, b) in (s, f(a, b)) }
                }
            }
        }.map{ ssz in StateT<F, S, Z>(ssz) }
    }
    
    public func ap<AA, B, Mon>(_ fa : StateT<F, S, AA>, _ monad : Mon) -> StateT<F, S, B> where Mon : Monad, Mon.F == F, A == (AA) -> B {
        return map2(fa, { f, a in f(a) }, monad)
    }
    
    public func product<B, Mon>(_ sb : StateT<F, S, B>, _ monad : Mon) -> StateT<F, S, (A, B)> where Mon : Monad, Mon.F == F {
        return self.map2(sb, { a, b in (a, b) }, monad)
    }
    
    public func flatMap<B, Mon>(_ f : @escaping (A) -> StateT<F, S, B>, _ monad : Mon) -> StateT<F, S, B> where Mon : Monad, Mon.F == F {
        return StateT<F, S, B>(
            monad.map(runF) { sfsa in
                sfsa >>> { fsa in
                    monad.flatMap(fsa) { (s, a) in
                        f(a).runM(s, monad)
                    }
                }
            }
        )
    }
    
    public func flatMapF<B, Mon>(_ f : @escaping (A) -> Kind<F, B>, _ monad : Mon) -> StateT<F, S, B> where Mon : Monad, Mon.F == F {
        return StateT<F, S, B>(
            monad.map(runF) { sfsa in
                sfsa >>> { fsa in
                    monad.flatMap(fsa) { (s, a) in
                        monad.map(f(a), { b in (s, b) })
                    }
                }
            }
        )
    }
    
    public func combineK<Mon, SemiG>(_ y : StateT<F, S, A>, _ monad : Mon, _ semigroup : SemiG) -> StateT<F, S, A> where Mon : Monad, Mon.F == F, SemiG : SemigroupK, SemiG.F == F {
        return StateT(
            monad.pure({ s in semigroup.combineK(self.runM(s, monad), y.runM(s, monad)) })
        )
    }
    
    public func runA<Mon>(_ s : S, _ monad : Mon) -> Kind<F, A> where Mon : Monad, Mon.F == F {
        return monad.map(runM(s, monad)){ (_, a) in a }
    }
    
    public func runS<Mon>(_ s : S, _ monad : Mon) -> Kind<F, S> where Mon : Monad, Mon.F == F {
        return monad.map(runM(s, monad)){ (s, _) in s }
    }
    
    public func runM<Mon>(_ initial : S, _ monad : Mon) -> Kind<F, (S, A)> where Mon : Monad, Mon.F == F {
        return monad.flatMap(runF, { f in f(initial) })
    }
}

public extension StateT where F == ForId {
    public func run(_ initialState : S) -> (S, A) {
        return self.runM(initialState, Id<A>.monad()).fix().value
    }
    
    public func runA(_ s : S) -> A {
        return run(s).1
    }
    
    public func runS(_ s : S) -> S {
        return run(s).0
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> StateOf<S, B> {
        return self.map(f, Id<A>.functor())
    }
    
    public func ap<AA, B>(_ ff : StateOf<S, AA>) -> StateOf<S, B> where A == (AA) -> B {
        return self.ap(ff, Id<A>.monad())
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> StateOf<S, B>) -> StateOf<S, B> {
        return self.flatMap(f, Id<A>.monad())
    }
    
    public func product<B>(_ sb : State<S, B>) -> StateOf<S, (A, B)> {
        return self.product(sb, Id<A>.monad())
    }
}

public extension StateT {
    public static func functor<FuncF>(_ functor : FuncF) -> StateTFunctor<F, S, FuncF> {
        return StateTFunctor<F, S, FuncF>(functor)
    }
    
    public static func applicative<MonF>(_ monad : MonF) -> StateTApplicative<F, S, MonF> {
        return StateTApplicative<F, S, MonF>(monad)
    }
    
    public static func monad<MonF>(_ monad : MonF) -> StateTMonad<F, S, MonF> {
        return StateTMonad<F, S, MonF>(monad)
    }
    
    public static func monadState<MonF>(_ monad : MonF) -> StateTMonadState<F, S, MonF> {
        return StateTMonadState<F, S, MonF>(monad)
    }
    
    public static func semigroupK<MonF, SemiKF>(_ monad : MonF, _ semigroupK : SemiKF) -> StateTSemigroupK<F, S, MonF, SemiKF> {
        return StateTSemigroupK<F, S, MonF, SemiKF>(monad, semigroupK)
    }
    
    public static func monadCombine<MonComF>(_ monadCombine : MonComF) -> StateTMonadCombine<F, S, MonComF> {
        return StateTMonadCombine<F, S, MonComF>(monadCombine)
    }
    
    public static func applicativeError<Err, MonErrF>(_ monadError : MonErrF) -> StateTMonadError<F, S, Err, MonErrF> {
        return StateTMonadError<F, S, Err, MonErrF>(monadError)
    }
    
    public static func monadError<Err, MonErrF>(_ monadError : MonErrF) -> StateTMonadError<F, S, Err, MonErrF> {
        return StateTMonadError<F, S, Err, MonErrF>(monadError)
    }
}

public class StateTFunctor<G, S, FuncG> : Functor where FuncG : Functor, FuncG.F == G {
    public typealias F = StateTPartial<G, S>
    
    private let functor : FuncG
    
    public init(_ functor : FuncG) {
        self.functor = functor
    }
    
    public func map<A, B>(_ fa: StateTOf<G, S, A>, _ f: @escaping (A) -> B) -> StateTOf<G, S, B> {
        return StateT.fix(fa).map(f, functor)
    }
}

public class StateTApplicative<G, S, MonG> : StateTFunctor<G, S, MonG>, Applicative where MonG : Monad, MonG.F == G {
    fileprivate let monad : MonG
    
    override public init(_ monad : MonG) {
        self.monad = monad
        super.init(monad)
    }
    
    public func pure<A>(_ a: A) -> StateTOf<G, S, A> {
        return StateT(monad.pure({ s in self.monad.pure((s, a))}))
    }
    
    public func ap<A, B>(_ ff: StateTOf<G, S, (A) -> B>, _ fa: StateTOf<G, S, A>) -> StateTOf<G, S, B> {
        return StateT.fix(ff).ap(StateT.fix(fa), monad)
    }
}

public class StateTMonad<G, S, MonG> : StateTApplicative<G, S, MonG>, Monad where MonG : Monad, MonG.F == G {
    
    public func flatMap<A, B>(_ fa: StateTOf<G, S, A>, _ f: @escaping (A) -> StateTOf<G, S, B>) -> StateTOf<G, S, B> {
        return StateT.fix(fa).flatMap({ a in StateT.fix(f(a)) }, monad)
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> StateTOf<G, S, Either<A, B>>) -> StateTOf<G, S, B> {
        return StateT.tailRecM(a, f, monad)
    }
}

public class StateTMonadState<G, R, MonG> : StateTMonad<G, R, MonG>, MonadState where MonG : Monad, MonG.F == G {
    public typealias S = R
    
    public func get() -> StateTOf<G, R, R> {
        return StateT<G, R, R>.get(monad)
    }
    
    public func set(_ s: R) -> StateTOf<G, R, ()> {
        return StateT<G, R, Unit>.set(s, monad)
    }
}

public class StateTSemigroupK<G, S, MonG, SemiKG> : SemigroupK where MonG : Monad, MonG.F == G, SemiKG : SemigroupK, SemiKG.F == G {
    public typealias F = StateTPartial<G, S>
    
    private let monad : MonG
    private let semigroupK : SemiKG
    
    public init(_ monad : MonG, _ semigroupK : SemiKG) {
        self.monad = monad
        self.semigroupK = semigroupK
    }
    
    public func combineK<A>(_ x: StateTOf<G, S, A>, _ y: StateTOf<G, S, A>) -> StateTOf<G, S, A> {
        return StateT.fix(x).combineK(StateT.fix(y), monad, semigroupK)
    }
}

public class StateTMonadCombine<G, S, MonComG> : StateTMonad<G, S, MonComG>, MonadCombine where MonComG : MonadCombine, MonComG.F == G {
    private let monadCombine : MonComG
    
    override public init(_ monadCombine : MonComG) {
        self.monadCombine = monadCombine
        super.init(monadCombine)
    }
    
    public func combineK<A>(_ x: StateTOf<G, S, A>, _ y: StateTOf<G, S, A>) -> StateTOf<G, S, A> {
        return StateT.fix(x).combineK(StateT.fix(y), monadCombine, monadCombine)
    }
    
    public func empty<A>() -> StateTOf<G, S, A> {
        return liftT(monadCombine.empty())
    }
    
    public func emptyK<A>() -> StateTOf<G, S, A> {
        return liftT(monadCombine.empty())
    }
    
    func liftT<A>(_ fa : Kind<G, A>) -> StateT<G, S, A> {
        return StateT(monad.pure({ s in self.monad.map(fa, { a in (s, a) }) }))
    }
}

public class StateTMonadError<G, S, Err, MonErrG> : StateTMonad<G, S, MonErrG>, MonadError where MonErrG : MonadError, MonErrG.F == G, MonErrG.E == Err {
    public typealias E = Err
    
    private let monadError : MonErrG
    
    override public init(_ monadError : MonErrG) {
        self.monadError = monadError
        super.init(monadError)
    }
    
    public func raiseError<A>(_ e: Err) -> StateTOf<G, S, A> {
        return StateT<G, S, A>.lift(monadError.raiseError(e), monadError)
    }
    
    public func handleErrorWith<A>(_ fa: StateTOf<G, S, A>, _ f: @escaping (Err) -> StateTOf<G, S, A>) -> StateTOf<G, S, A> {
        return StateT<G, S, A>(monadError.pure({ s in
            self.monadError.handleErrorWith(StateT.fix(fa).runM(s, self.monadError), { e in
                StateT.fix(f(e)).runM(s, self.monadError)
            })
        }))
    }
}
