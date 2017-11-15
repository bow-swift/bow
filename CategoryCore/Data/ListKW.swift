//
//  ListKW.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 11/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class ListKWF {}

public class ListKW<A> : HK<ListKWF, A> {
    fileprivate let list : [A]
    
    public static func +(lhs : ListKW<A>, rhs : ListKW<A>) -> ListKW<A> {
        return ListKW(lhs.list + rhs.list)
    }
    
    public static func pure(_ a : A) -> ListKW<A> {
        return ListKW([a])
    }
    
    public static func empty() -> ListKW<A> {
        return ListKW([])
    }
    
    private static func go<B>(_ buf : [B], _ f : (A) -> HK<ListKWF, Either<A, B>>, _ v : ListKW<Either<A, B>>) -> [B] {
        if !v.isEmpty {
            let head = v.list[0]
            return head.fold({ a in go(buf, f, ListKW<Either<A, B>>(f(a).ev().list + v.list.dropFirst())) },
                      { b in
                            let newBuf = buf + [b]
                            return go(newBuf, f, ListKW<Either<A, B>>([Either<A, B>](v.list.dropFirst())))
                      })
        } else {
            return buf
        }
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> HK<ListKWF, Either<A, B>>) -> ListKW<B> {
        return ListKW<B>(go([], f, f(a).ev()))
    }
    
    public init(_ list : [A]) {
        self.list = list
    }
    
    public var asArray : [A] {
        return list
    }
    
    public var isEmpty : Bool {
        return list.isEmpty
    }
    
    public func map<B>(_ f : (A) -> B) -> ListKW<B> {
        return ListKW<B>(self.list.map(f))
    }
    
    public func ap<B>(_ ff : ListKW<(A) -> B>) -> ListKW<B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : (A) -> ListKW<B>) -> ListKW<B> {
        return ListKW<B>(list.flatMap({ a in f(a).list }))
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return list.reduce(b, f)
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        func loop(_ lkw : ListKW<A>) -> Eval<B> {
            if lkw.list.isEmpty {
                return b
            } else {
                return f(lkw.list[0], Eval.deferEvaluation({ loop(ListKW([A](lkw.list.dropFirst())))  }))
            }
        }
        return Eval.deferEvaluation({ loop(self) })
    }
    
    public func traverse<G, B, Appl>(_ f : @escaping (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, HK<ListKWF, B>> where Appl : Applicative, Appl.F == G {
        let x = foldR(Eval.always({ applicative.pure(ListKW<B>([])) }),
                     { a, eval in applicative.map2Eval(f(a), eval, { x, y in ListKW<B>([x]) + y }) }).value()
        return applicative.map(x, { a in a as HK<ListKWF, B> })
    }
    
    public func map2<B, Z>(_ fb : ListKW<B>, _ f : ((A, B)) -> Z) -> ListKW<Z> {
        return self.flatMap { a in
            fb.map{ b in
                f((a, b))
            }
        }
    }
    
    public func mapFilter<B>(_ f : (A) -> Maybe<B>) -> ListKW<B> {
        return flatMap { a in f(a).fold(ListKW<B>.empty, ListKW<B>.pure) }
    }
    
    public func combineK(_ y : ListKW<A>) -> ListKW<A> {
        return self + y
    }
}

public extension HK where F == ListKWF {
    public func ev() -> ListKW<A> {
        return self as! ListKW<A>
    }
}

public extension Array {
    public func k() -> ListKW<Element> {
        return ListKW(self)
    }
}

public extension ListKW {
    public static func functor() -> ListKWFunctor {
        return ListKWFunctor()
    }
    
    public static func applicative() -> ListKWApplicative {
        return ListKWApplicative()
    }
    
    public static func monad() -> ListKWMonad {
        return ListKWMonad()
    }
    
    public static func foldable() -> ListKWFoldable {
        return ListKWFoldable()
    }
    
    public static func traverse() -> ListKWTraverse {
        return ListKWTraverse()
    }
    
    public static func semigroup() -> ListKWSemigroup<A> {
        return ListKWSemigroup<A>()
    }
    
    public static func semigroupK() -> ListKWSemigroupK {
        return ListKWSemigroupK()
    }
    
    public static func monoid() -> ListKWMonoid<A> {
        return ListKWMonoid<A>()
    }
    
    public static func monoidK() -> ListKWMonoidK {
        return ListKWMonoidK()
    }
    
    public static func functorFilter() -> ListKWFunctorFilter {
        return ListKWFunctorFilter()
    }
    
    public static func monadFilter() -> ListKWMonadFilter {
        return ListKWMonadFilter()
    }
    
    public static func monadCombine() -> ListKWMonadCombine {
        return ListKWMonadCombine()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> ListKWEq<A, EqA> {
        return ListKWEq<A, EqA>(eqa)
    }
}

public class ListKWFunctor : Functor {
    public typealias F = ListKWF
    
    public func map<A, B>(_ fa: HK<ListKWF, A>, _ f: @escaping (A) -> B) -> HK<ListKWF, B> {
        return fa.ev().map(f)
    }
}

public class ListKWApplicative : ListKWFunctor, Applicative {
    public func pure<A>(_ a: A) -> HK<ListKWF, A> {
        return ListKW.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<ListKWF, A>, _ ff: HK<ListKWF, (A) -> B>) -> HK<ListKWF, B> {
        return fa.ev().ap(ff.ev())
    }
}

public class ListKWMonad : ListKWApplicative, Monad {
    public func flatMap<A, B>(_ fa: HK<ListKWF, A>, _ f: @escaping (A) -> HK<ListKWF, B>) -> HK<ListKWF, B> {
        return fa.ev().flatMap({ a in f(a).ev() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<ListKWF, Either<A, B>>) -> HK<ListKWF, B> {
        return ListKW.tailRecM(a, f)
    }
}

public class ListKWFoldable : Foldable {
    public typealias F = ListKWF
    
    public func foldL<A, B>(_ fa: HK<ListKWF, A>, _ b: B, _ f: (B, A) -> B) -> B {
        return fa.ev().foldL(b, f)
    }
    
    public func foldR<A, B>(_ fa: HK<ListKWF, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.ev().foldR(b, f)
    }
}

public class ListKWTraverse : ListKWFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: HK<ListKWF, A>, _ f: @escaping (A) -> HK<G, B>, _ applicative: Appl) -> HK<G, HK<ListKWF, B>> where G == Appl.F, Appl : Applicative {
        return fa.ev().traverse(f, applicative)
    }
}

public class ListKWSemigroupK : SemigroupK {
    public typealias F = ListKWF
    
    public func combineK<A>(_ x: HK<ListKWF, A>, _ y: HK<ListKWF, A>) -> HK<ListKWF, A> {
        return x.ev().combineK(y.ev())
    }
}

public class ListKWMonoidK : ListKWSemigroupK, MonoidK {
    public func emptyK<A>() -> HK<ListKWF, A> {
        return ListKW<A>.empty()
    }
}

public class ListKWFunctorFilter : ListKWFunctor, FunctorFilter {
    public func mapFilter<A, B>(_ fa: HK<ListKWF, A>, _ f: (A) -> Maybe<B>) -> HK<ListKWF, B> {
        return fa.ev().mapFilter(f)
    }
}

public class ListKWMonadFilter : ListKWMonad, MonadFilter {
    public func empty<A>() -> HK<ListKWF, A> {
        return ListKW<A>.empty()
    }
    
    public func mapFilter<A, B>(_ fa: HK<ListKWF, A>, _ f: (A) -> Maybe<B>) -> HK<ListKWF, B> {
        return fa.ev().mapFilter(f)
    }
}

public class ListKWMonadCombine : ListKWMonadFilter, MonadCombine {
    public func emptyK<A>() -> HK<ListKWF, A> {
        return ListKW<A>.empty()
    }
    
    public func combineK<A>(_ x: HK<ListKWF, A>, _ y: HK<ListKWF, A>) -> HK<ListKWF, A> {
        return x.ev().combineK(y.ev())
    }
}

public class ListKWSemigroup<R> : Semigroup {
    public typealias A = ListKW<R>
    
    public func combine(_ a: ListKW<R>, _ b: ListKW<R>) -> ListKW<R> {
        return a + b
    }
}

public class ListKWMonoid<R> : ListKWSemigroup<R>, Monoid {
    public var empty: ListKW<R> {
        return ListKW<R>.empty()
    }
}

public class ListKWEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = ListKW<R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: ListKW<R>, _ b: ListKW<R>) -> Bool {
        if a.list.count != b.list.count {
            return false
        } else {
            return zip(a.list, b.list).map{ aa, bb in eqr.eqv(aa, bb) }.reduce(true, and)
        }
    }
}


