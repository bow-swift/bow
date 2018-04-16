//
//  Cofree.swift
//  Bow
//
//  Created by Tomás Ruiz López on 13/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class CofreeF {}
public typealias CofreeEval<S, A> = HK<S, Cofree<S, A>>
public typealias CofreePartial<S> = HK<CofreeF, S>

public class Cofree<S, A> : HK2<CofreeF, S, A> {
    private let head : A
    private let tail : Eval<CofreeEval<S, A>>
    
    public static func unfold<Func>(_ a : A, _ f : @escaping (A) -> HK<S, A>, _ functor : Func) -> Cofree<S, A> where Func : Functor, Func.F == S {
        return create(a, f, functor)
    }
    
    public static func create<Func>(_ a : A, _ f : @escaping (A) -> HK<S, A>, _ functor : Func) -> Cofree<S, A> where Func : Functor, Func.F == S {
        return Cofree(a, Eval.later({ functor.map(f(a), { inA in create(inA, f, functor) }) }))
    }
    
    public static func fix(_ fa : HK2<CofreeF, S, A>) -> Cofree<S, A> {
        return fa as! Cofree<S, A>
    }
    
    public init(_ head : A, _ tail : Eval<CofreeEval<S, A>>) {
        self.head = head
        self.tail = tail
    }
    
    public func tailForced() -> CofreeEval<S, A> {
        return tail.value()
    }
    
    public func transform<B, Func>(_ f : @escaping (A) -> B, _ g : @escaping (Cofree<S, A>) -> Cofree<S, B>, _ functor : Func) -> Cofree<S, B> where Func : Functor, Func.F == S {
        return Cofree<S, B>(f(head), tail.map{ coevsa in functor.map(coevsa, g) })
    }
    
    public func map<B, Func>(_ f : @escaping (A) -> B, _ functor : Func) -> Cofree<S, B> where Func : Functor, Func.F == S {
        return transform(f, { cofsa in cofsa.map(f, functor) }, functor)
    }
    
    public func mapBranchingRoot<FuncK>(_ functionK : FuncK) -> Cofree<S, A> where FuncK : FunctionK, FuncK.F == S, FuncK.G == S {
        return Cofree(head, tail.map{ coevsa in functionK.invoke(coevsa) })
    }
    
    public func mapBranchingS<T, FuncK, FuncS, FuncT>(_ functionK : FuncK, _ functorS : FuncS, _ functorT : FuncT) -> Cofree<T, A> where FuncK : FunctionK, FuncK.F == S, FuncK.G == T, FuncS : Functor, FuncS.F == S, FuncT : Functor, FuncT.F == T {
        return Cofree<T, A>(head, tail.map{ ce in functionK.invoke(functorS.map(ce, { cof in cof.mapBranchingS(functionK, functorS, functorT) })) })
    }
    
    public func mapBranchingT<T, FuncK, FuncS, FuncT>(_ functionK : FuncK, _ functorS : FuncS, _ functorT : FuncT) -> Cofree<T, A> where FuncK : FunctionK, FuncK.F == S, FuncK.G == T, FuncS : Functor, FuncS.F == S, FuncT : Functor, FuncT.F == T {
        return Cofree<T, A>(head, tail.map{ ce in functorT.map(functionK.invoke(ce), { cof in cof.mapBranchingT(functionK, functorS, functorT) }) })
    }
    
    public func coflatMap<B, Func>(_ f : @escaping (Cofree<S, A>) -> B, _ functor : Func) -> Cofree<S, B> where Func : Functor, Func.F == S {
        return Cofree<S, B>(f(self), tail.map{ coevsa in functor.map(coevsa, { _ in self.coflatMap(f, functor) }) })
    }
    
    public func duplicate<Func>(_ functor : Func) -> Cofree<S, Cofree<S, A>> where Func : Functor, Func.F == S {
        return Cofree<S, Cofree<S, A>>(self, tail.map{ coevsa in functor.map(coevsa, { _ in self.duplicate(functor) }) })
    }
    
    public func runTail() -> Cofree<S, A> {
        return Cofree(head, Eval.now(tail.value()))
    }
    
    public func run<Func>(_ functor : Func) -> Cofree<S, A> where Func : Functor, Func.F == S {
        return Cofree(head, Eval.now(tail.map{ coevsa in functor.map(coevsa, { cof in cof.run(functor) }) }.value()))
    }
    
    public func extract() -> A {
        return head
    }
    
    public func cata<B, Trav>(_ folder : @escaping (A, HK<S, B>) -> Eval<B>, _ traverse : Trav) -> Eval<B> where Trav : Traverse, Trav.F == S {
        let ev = traverse.traverse(self.tailForced(), { cof in cof.cata(folder, traverse) }, Eval<B>.applicative()).fix()
        return ev.flatMap { sb in folder(self.extract(), sb) }
    }
    
    public func cataM<B, M, FuncK, Trav, Mon>(_ folder : @escaping (A, HK<S, B>) -> HK<M, B>, _ inclusion : FuncK, _ traverse : Trav, _ monad : Mon) -> HK<M, B> where FuncK : FunctionK, FuncK.F == EvalF, FuncK.G == M, Trav : Traverse, Trav.F == S, Mon : Monad, Mon.F == M {
        func loop(_ ev : Cofree<S, A>) -> Eval<HK<M, B>> {
            let looped = traverse.traverse(ev.tailForced(), { cof in  monad.flatten(inclusion.invoke(Eval.deferEvaluation({ loop(cof) }))) }, monad)
            let folded = monad.flatMap(looped, { fb in folder(ev.head, fb) })
            return Eval.now(folded)
        }
        return monad.flatten(inclusion.invoke(loop(self)))
    }
}

public extension Cofree {
    public static func functor<Func>(_ functor : Func) -> CofreeFunctor<S, Func> {
        return CofreeFunctor<S, Func>(functor)
    }
    
    public static func comonad<Func>(_ functor : Func) -> CofreeComonad<S, Func> {
        return CofreeComonad<S, Func>(functor)
    }
}

public class CofreeFunctor<S, Func> : Functor where Func : Functor, Func.F == S {
    public typealias F = CofreePartial<S>
    
    fileprivate let functor : Func
    
    public init(_ functor : Func) {
        self.functor = functor
    }
    
    public func map<A, B>(_ fa: HK<HK<CofreeF, S>, A>, _ f: @escaping (A) -> B) -> HK<HK<CofreeF, S>, B> {
        return Cofree.fix(fa).map(f, functor)
    }
}

public class CofreeComonad<S, Func> : CofreeFunctor<S, Func>, Comonad where Func : Functor, Func.F == S {
    
    public func coflatMap<A, B>(_ fa: HK<HK<CofreeF, S>, A>, _ f: @escaping (HK<HK<CofreeF, S>, A>) -> B) -> HK<HK<CofreeF, S>, B> {
        return Cofree.fix(fa).coflatMap(f, functor)
    }
    
    public func extract<A>(_ fa: HK<HK<CofreeF, S>, A>) -> A {
        return Cofree.fix(fa).extract()
    }
}
