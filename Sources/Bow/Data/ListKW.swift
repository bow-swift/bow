//
//  ListKW.swift
//  Bow
//
//  Created by Tomás Ruiz López on 11/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class ListKWKind {}

public class ListKW<A> : Kind<ListKWKind, A> {
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
    
    private static func go<B>(_ buf : [B], _ f : (A) -> Kind<ListKWKind, Either<A, B>>, _ v : ListKW<Either<A, B>>) -> [B] {
        if !v.isEmpty {
            let head = v.list[0]
            return head.fold({ a in go(buf, f, ListKW<Either<A, B>>(f(a).fix().list + v.list.dropFirst())) },
                      { b in
                            let newBuf = buf + [b]
                            return go(newBuf, f, ListKW<Either<A, B>>([Either<A, B>](v.list.dropFirst())))
                      })
        } else {
            return buf
        }
    }
    
    public static func tailRecM<B>(_ a : A, _ f : (A) -> Kind<ListKWKind, Either<A, B>>) -> ListKW<B> {
        return ListKW<B>(go([], f, f(a).fix()))
    }
    
    public static func fix(_ fa : Kind<ListKWKind, A>) -> ListKW<A> {
        return fa.fix()
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
    
    public func traverse<G, B, Appl>(_ f : @escaping (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, Kind<ListKWKind, B>> where Appl : Applicative, Appl.F == G {
        let x = foldR(Eval.always({ applicative.pure(ListKW<B>([])) }),
                     { a, eval in applicative.map2Eval(f(a), eval, { x, y in ListKW<B>([x]) + y }) }).value()
        return applicative.map(x, { a in a as Kind<ListKWKind, B> })
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

public extension Kind where F == ListKWKind {
    public func fix() -> ListKW<A> {
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
    public typealias F = ListKWKind
    
    public func map<A, B>(_ fa: Kind<ListKWKind, A>, _ f: @escaping (A) -> B) -> Kind<ListKWKind, B> {
        return fa.fix().map(f)
    }
}

public class ListKWApplicative : ListKWFunctor, Applicative {
    public func pure<A>(_ a: A) -> Kind<ListKWKind, A> {
        return ListKW.pure(a)
    }
    
    public func ap<A, B>(_ fa: Kind<ListKWKind, A>, _ ff: Kind<ListKWKind, (A) -> B>) -> Kind<ListKWKind, B> {
        return fa.fix().ap(ff.fix())
    }
}

public class ListKWMonad : ListKWApplicative, Monad {
    public func flatMap<A, B>(_ fa: Kind<ListKWKind, A>, _ f: @escaping (A) -> Kind<ListKWKind, B>) -> Kind<ListKWKind, B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ListKWKind, Either<A, B>>) -> Kind<ListKWKind, B> {
        return ListKW.tailRecM(a, f)
    }
}

public class ListKWFoldable : Foldable {
    public typealias F = ListKWKind
    
    public func foldL<A, B>(_ fa: Kind<ListKWKind, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldL(b, f)
    }
    
    public func foldR<A, B>(_ fa: Kind<ListKWKind, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldR(b, f)
    }
}

public class ListKWTraverse : ListKWFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: Kind<ListKWKind, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, Kind<ListKWKind, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

public class ListKWSemigroupK : SemigroupK {
    public typealias F = ListKWKind
    
    public func combineK<A>(_ x: Kind<ListKWKind, A>, _ y: Kind<ListKWKind, A>) -> Kind<ListKWKind, A> {
        return x.fix().combineK(y.fix())
    }
}

public class ListKWMonoidK : ListKWSemigroupK, MonoidK {
    public func emptyK<A>() -> Kind<ListKWKind, A> {
        return ListKW<A>.empty()
    }
}

public class ListKWFunctorFilter : ListKWFunctor, FunctorFilter {
    public func mapFilter<A, B>(_ fa: Kind<ListKWKind, A>, _ f: @escaping (A) -> Maybe<B>) -> Kind<ListKWKind, B> {
        return fa.fix().mapFilter(f)
    }
}

public class ListKWMonadFilter : ListKWMonad, MonadFilter {
    public func empty<A>() -> Kind<ListKWKind, A> {
        return ListKW<A>.empty()
    }
    
    public func mapFilter<A, B>(_ fa: Kind<ListKWKind, A>, _ f: @escaping (A) -> Maybe<B>) -> Kind<ListKWKind, B> {
        return fa.fix().mapFilter(f)
    }
}

public class ListKWMonadCombine : ListKWMonadFilter, MonadCombine {
    public func emptyK<A>() -> Kind<ListKWKind, A> {
        return ListKW<A>.empty()
    }
    
    public func combineK<A>(_ x: Kind<ListKWKind, A>, _ y: Kind<ListKWKind, A>) -> Kind<ListKWKind, A> {
        return x.fix().combineK(y.fix())
    }
}

public class ListKWSemigroup<R> : Semigroup {
    public typealias A = Kind<ListKWKind, R>
    
    public func combine(_ a: Kind<ListKWKind, R>, _ b: Kind<ListKWKind, R>) -> Kind<ListKWKind, R> {
        return ListKW.fix(a) + ListKW.fix(b)
    }
}

public class ListKWMonoid<R> : ListKWSemigroup<R>, Monoid {
    public var empty: Kind<ListKWKind, R> {
        return ListKW<R>.empty()
    }
}

public class ListKWEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = Kind<ListKWKind, R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: Kind<ListKWKind, R>, _ b: Kind<ListKWKind, R>) -> Bool {
        let a = ListKW.fix(a)
        let b = ListKW.fix(b)
        if a.list.count != b.list.count {
            return false
        } else {
            return zip(a.list, b.list).map{ aa, bb in eqr.eqv(aa, bb) }.reduce(true, and)
        }
    }
}


