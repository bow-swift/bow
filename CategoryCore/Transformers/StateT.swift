//
//  StateT.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 5/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class StateTF {}
public typealias StateTPartial<F, S> = HK2<StateTF, F, S>

public class StateT<F, S, A> : HK3<StateTF, F, S, A> {
    private let runF : HK<F, (S) -> HK<F, (S,A)>>
    
    public static func lift<Mon>(_ fa : HK<F, A>, _ monad : Mon) -> StateT<F, S, A> where Mon : Monad, Mon.F == F {
        return StateT(monad.pure({ s in monad.map(fa, { a in (s, a) }) }))
    }
    
    public static func get<Appl>(_ applicative : Appl) -> StateT<F, S, S> where Appl : Applicative, Appl.F == F {
        return StateT<F, S, S>(applicative.pure({ s in applicative.pure((s, s)) }))
    }
    
    public static func set<Appl>(_ s : S, _ applicative : Appl) -> StateT<F, S, ()> where Appl : Applicative, Appl.F == F {
        return StateT<F, S, ()>(applicative.pure({ _ in applicative.pure((s, ())) }))
    }
    
    public static func tailRecM<B, Mon>(_ a : A, _ f : @escaping (A) -> HK<StateTPartial<F, S>, Either<A, B>>, _ monad : Mon) -> StateT<F, S, B> where Mon : Monad, Mon.F == F {
        return StateT<F, S, B>(monad.pure({ s in
            monad.tailRecM((s, a), { pair in
                monad.map((f(pair.1) as! StateT<F, S, Either<A, B>>).runM(pair.0, monad), { sss, ab in
                    ab.bimap({ left in (sss, left) }, { right in (sss, right) })
                })
            })
        }))
    }
    
    public init(_ runF : HK<F, (S) -> HK<F, (S,A)>>) {
        self.runF = runF
    }
    
    public func transform<B, Func>(_ f : @escaping (S, A) -> (S, B), _ functor : Func) -> StateT<F, S, B> where Func : Functor, Func.F == F {
        return StateT<F, S, B>(
            functor.map(runF, { sfsa in
                sfsa >> { fsa in functor.map(fsa, f) }
            })
        )
    }
    
    public func map<B, Func>(_ f : @escaping (A) -> B, _ functor : Func) -> StateT<F, S, B> where Func : Functor, Func.F == F {
        return transform({ (s, a) in (s, f(a)) }, functor)
    }
    
    public func map2<B, Z, Mon>(_ sb : StateT<F, S, B>, _ f : @escaping (A, B) -> Z, _ monad : Mon) -> StateT<F, S, Z> where Mon : Monad, Mon.F == F {
        return StateT<F, S, Z>(monad.map2(runF, sb.runF, { ssa, ssb in
            ssa >> { fsa in
                monad.flatMap(fsa) { (s, a) in
                    monad.map(ssb(s), { (s, b) in (s, f(a, b)) })
                }
            }
        }))
    }
    
    public func map2Eval<B, Z, Mon>(_ esb : Eval<StateT<F, S, B>>, _ f : @escaping (A, B) -> Z, _ monad : Mon) -> Eval<StateT<F, S, Z>> where Mon : Monad, Mon.F == F {
        return monad.map2Eval(runF, esb.map{ sb in sb.runF }){ ssa, ssb in
            ssa >> { fsa in
                monad.flatMap(fsa) { (s, a) in
                    monad.map(ssb(s)) { (s, b) in (s, f(a, b)) }
                }
            }
        }.map{ ssz in StateT<F, S, Z>(ssz) }
    }
    
    public func ap<B, Mon>(_ ff : StateT<F, S, (A) -> B>, _ monad : Mon) -> StateT<F, S, B> where Mon : Monad, Mon.F == F {
        return ff.map2(self, { f, a in f(a) }, monad)
    }
    
    public func product<B, Mon>(_ sb : StateT<F, S, B>, _ monad : Mon) -> StateT<F, S, (A, B)> where Mon : Monad, Mon.F == F {
        return self.map2(sb, { a, b in (a, b) }, monad)
    }
    
    public func flatMap<B, Mon>(_ f : @escaping (A) -> StateT<F, S, B>, _ monad : Mon) -> StateT<F, S, B> where Mon : Monad, Mon.F == F {
        return StateT<F, S, B>(
            monad.map(runF) { sfsa in
                sfsa >> { fsa in
                    monad.flatMap(fsa) { (s, a) in
                        f(a).run(s, monad)
                    }
                }
            }
        )
    }
    
    public func flatMapF<B, Mon>(_ f : @escaping (A) -> HK<F, B>, _ monad : Mon) -> StateT<F, S, B> where Mon : Monad, Mon.F == F {
        return StateT<F, S, B>(
            monad.map(runF) { sfsa in
                sfsa >> { fsa in
                    monad.flatMap(fsa) { (s, a) in
                        monad.map(f(a), { b in (s, b) })
                    }
                }
            }
        )
    }
    
    public func combineK<Mon, SemiG>(_ y : StateT<F, S, A>, _ monad : Mon, _ semigroup : SemiG) -> StateT<F, S, A> where Mon : Monad, Mon.F == F, SemiG : SemigroupK, SemiG.F == F {
        return StateT(
            monad.pure({ s in semigroup.combineK(self.run(s, monad), y.run(s, monad)) })
        )
    }
    
    public func run<Mon>(_ initial : S, _ monad : Mon) -> HK<F, (S, A)> where Mon : Monad, Mon.F == F {
        return monad.flatMap(runF, { f in f(initial) })
    }
    
    public func runA<Mon>(_ s : S, _ monad : Mon) -> HK<F, A> where Mon : Monad, Mon.F == F {
        return monad.map(run(s, monad)){ (_, a) in a }
    }
    
    public func runS<Mon>(_ s : S, _ monad : Mon) -> HK<F, S> where Mon : Monad, Mon.F == F {
        return monad.map(run(s, monad)){ (s, _) in s }
    }
    
    public func runM<Mon>(_ initial : S, _ monad : Mon) -> HK<F, (S, A)> where Mon : Monad, Mon.F == F {
        return self.run(initial, monad)
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
    
    public func map<A, B>(_ fa: HK<HK<HK<StateTF, G>, S>, A>, _ f: @escaping (A) -> B) -> HK<HK<HK<StateTF, G>, S>, B> {
        return (fa as! StateT<G, S, A>).map(f, functor)
    }
}

public class StateTApplicative<G, S, MonG> : StateTFunctor<G, S, MonG>, Applicative where MonG : Monad, MonG.F == G {
    fileprivate let monad : MonG
    
    override public init(_ monad : MonG) {
        self.monad = monad
        super.init(monad)
    }
    
    public func pure<A>(_ a: A) -> HK<HK<HK<StateTF, G>, S>, A> {
        return StateT(monad.pure({ s in self.monad.pure((s, a))}))
    }
    
    public func ap<A, B>(_ fa: HK<HK<HK<StateTF, G>, S>, A>, _ ff: HK<HK<HK<StateTF, G>, S>, (A) -> B>) -> HK<HK<HK<StateTF, G>, S>, B> {
        return (fa as! StateT<G, S, A>).ap(ff as! StateT<G, S, (A) -> B>, monad)
    }
}

public class StateTMonad<G, S, MonG> : StateTApplicative<G, S, MonG>, Monad where MonG : Monad, MonG.F == G {
    
    public func flatMap<A, B>(_ fa: HK<HK<HK<StateTF, G>, S>, A>, _ f: @escaping (A) -> HK<HK<HK<StateTF, G>, S>, B>) -> HK<HK<HK<StateTF, G>, S>, B> {
        return (fa as! StateT<G, S, A>).flatMap({ a in f(a) as! StateT<G, S, B>}, monad)
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<HK<HK<StateTF, G>, S>, Either<A, B>>) -> HK<HK<HK<StateTF, G>, S>, B> {
        return StateT.tailRecM(a, f, monad)
    }
}

public class StateTMonadState<G, R, MonG> : StateTMonad<G, R, MonG>, MonadState where MonG : Monad, MonG.F == G {
    public typealias S = R
    
    public func get() -> HK<HK<HK<StateTF, G>, R>, R> {
        return StateT<G, R, R>.get(monad)
    }
    
    public func set(_ s: R) -> HK<HK<HK<StateTF, G>, R>, ()> {
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
    
    public func combineK<A>(_ x: HK<HK<HK<StateTF, G>, S>, A>, _ y: HK<HK<HK<StateTF, G>, S>, A>) -> HK<HK<HK<StateTF, G>, S>, A> {
        return (x as! StateT<G, S, A>).combineK(y as! StateT<G, S, A>, monad, semigroupK)
    }
}

public class StateTMonadCombine<G, S, MonComG> : StateTMonad<G, S, MonComG>, MonadCombine where MonComG : MonadCombine, MonComG.F == G {
    private let monadCombine : MonComG
    
    override public init(_ monadCombine : MonComG) {
        self.monadCombine = monadCombine
        super.init(monadCombine)
    }
    
    public func combineK<A>(_ x: HK<HK<HK<StateTF, G>, S>, A>, _ y: HK<HK<HK<StateTF, G>, S>, A>) -> HK<HK<HK<StateTF, G>, S>, A> {
        return (x as! StateT<G, S, A>).combineK(y as! StateT<G, S, A>, monadCombine, monadCombine)
    }
    
    public func empty<A>() -> HK<HK<HK<StateTF, G>, S>, A> {
        return liftT(monadCombine.empty())
    }
    
    public func emptyK<A>() -> HK<HK<HK<StateTF, G>, S>, A> {
        return liftT(monadCombine.empty())
    }
    
    func liftT<A>(_ fa : HK<G, A>) -> StateT<G, S, A> {
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
    
    public func raiseError<A>(_ e: Err) -> HK<HK<HK<StateTF, G>, S>, A> {
        return StateT<G, S, A>.lift(monadError.raiseError(e), monadError)
    }
    
    public func handleErrorWith<A>(_ fa: HK<HK<HK<StateTF, G>, S>, A>, _ f: @escaping (Err) -> HK<HK<HK<StateTF, G>, S>, A>) -> HK<HK<HK<StateTF, G>, S>, A> {
        return StateT<G, S, A>(monadError.pure({ s in
            self.monadError.handleErrorWith((fa as! StateT<G, S, A>).runM(s, self.monadError), { e in
                (f(e) as! StateT<G, S, A>).runM(s, self.monadError)
            })
        }))
    }
}
