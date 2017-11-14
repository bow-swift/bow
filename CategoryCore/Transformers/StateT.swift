//
//  StateT.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 5/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class StateTF {}

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
}
