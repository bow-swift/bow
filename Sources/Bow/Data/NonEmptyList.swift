//
//  NonEmptyList.swift
//  Bow
//
//  Created by Tomás Ruiz López on 11/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class NonEmptyListF {}

public typealias Nel<A> = NonEmptyList<A>

public class NonEmptyList<A> : HK<NonEmptyListF, A> {
    private let head : A
    private let tail : [A]
    
    public static func +(lhs : NonEmptyList<A>, rhs : NonEmptyList<A>) -> NonEmptyList<A> {
        return NonEmptyList(head: lhs.head, tail: lhs.tail + [rhs.head] + rhs.tail)
    }
    
    public static func +(lhs : NonEmptyList<A>, rhs : [A]) -> NonEmptyList<A> {
        return NonEmptyList(head: lhs.head, tail: lhs.tail + rhs)
    }
    
    public static func +(lhs : NonEmptyList<A>, rhs : A) -> NonEmptyList<A> {
        return NonEmptyList(head: lhs.head, tail: lhs.tail + [rhs])
    }
    
    public static func of(_ head : A, _ tail : A...) -> NonEmptyList<A> {
        return NonEmptyList(head: head, tail: tail)
    }
    
    public static func fromArray(_ array : [A]) -> Maybe<NonEmptyList<A>> {
        return array.isEmpty ? Maybe<NonEmptyList<A>>.none() : Maybe<NonEmptyList<A>>.some(NonEmptyList(all: array))
    }
    
    public static func fromArrayUnsafe(_ array : [A]) -> NonEmptyList<A> {
        return NonEmptyList(all: array)
    }
    
    public static func pure(_ a : A) -> NonEmptyList<A> {
        return of(a)
    }
    
    private static func go<B>(_  buf : [B], _ f : @escaping (A) -> HK<NonEmptyListF, Either<A, B>>, _ v : NonEmptyList<Either<A, B>>) -> [B] {
        let head = v.head
        return head.fold({ a in go(buf, f, f(a).ev() + v.tail) },
                  { b in
                    let newBuf = buf + [b]
                    let x = NonEmptyList<Either<A, B>>.fromArray(v.tail)
                    return x.fold({ newBuf },
                                  { value in go(newBuf, f, value) })
                  })
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> HK<NonEmptyListF, Either<A, B>>) -> NonEmptyList<B> {
        return NonEmptyList<B>.fromArrayUnsafe(go([], f, f(a).ev()))
    }
    
    public static func ev(_ fa : HK<NonEmptyListF, A>) -> NonEmptyList<A> {
        return fa.ev()
    }
    
    public init(head : A, tail : [A]) {
        self.head = head
        self.tail = tail
    }
    
    private init(all : [A]) {
        self.head = all[0]
        self.tail = [A](all.dropFirst(1))
    }
    
    public var count : Int {
        return 1 + tail.count
    }
    
    public let isEmpty = false
    
    public func all() -> [A] {
        return [head] + tail
    }
    
    public func map<B>(_ f : (A) -> B) -> NonEmptyList<B> {
        return NonEmptyList<B>(head: f(head), tail: tail.map(f))
    }
    
    public func flatMap<B>(_ f : (A) -> NonEmptyList<B>) -> NonEmptyList<B> {
        return f(head) + tail.flatMap{ a in f(a).all() }
    }
    
    public func ap<B>(_ ff : NonEmptyList<(A) -> B>) -> NonEmptyList<B> {
        return ff.flatMap(map)
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return tail.reduce(f(b, head), f)
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return ListKW<A>.foldable().foldR(self.all().k(), b, f)
    }
    
    public func traverse<G, B, Appl>(_ f : @escaping (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, HK<NonEmptyListF, B>> where Appl : Applicative, Appl.F == G {
        return applicative.map2Eval(f(self.head),
                                    Eval<HK<G, HK<ListKWF, B>>>.always({ ListKW<A>.traverse().traverse(ListKW<A>(self.tail), f, applicative) }),
                                    { (a : B, b : HK<ListKWF, B>) in NonEmptyList<B>(head: a, tail: b.fix().asArray) }).value()
    }
    
    public func coflatMap<B>(_ f : @escaping (NonEmptyList<A>) -> B) -> NonEmptyList<B> {
        func consume(_ list : [A], _ buf : [B] = []) -> [B] {
            if list.isEmpty {
                return buf
            } else {
                let tail = [A](list.dropFirst())
                let newBuf = buf + [f(NonEmptyList(head: list[0], tail: tail))]
                return consume(tail, newBuf)
            }
        }
        return NonEmptyList<B>(head: f(self), tail: consume(self.tail))
    }
    
    public func extract() -> A {
        return head
    }
    
    public func combineK(_ y : NonEmptyList<A>) -> NonEmptyList<A> {
        return self + y
    }
}

public extension NonEmptyList where A : Equatable {
    public func contains(element : A) -> Bool {
        return head == element || tail.contains(where: { $0 == element })
    }
    
    public func containsAll(elements: [A]) -> Bool {
        return elements.map(contains).reduce(true, and)
    }
}

extension NonEmptyList : CustomStringConvertible {
    public var description : String {
        return "NonEmptyList(\(self.all())"
    }
}

public extension HK where F == NonEmptyListF {
    public func ev() -> NonEmptyList<A> {
        return self as! NonEmptyList<A>
    }
}

public extension NonEmptyList {
    public static func functor() -> NonEmptyListFunctor {
        return NonEmptyListFunctor()
    }
    
    public static func applicative() -> NonEmptyListApplicative {
        return NonEmptyListApplicative()
    }
    
    public static func monad() -> NonEmptyListMonad {
        return NonEmptyListMonad()
    }
    
    public static func comonad() -> NonEmptyListBimonad {
        return NonEmptyListBimonad()
    }
    
    public static func bimonad() -> NonEmptyListBimonad {
        return NonEmptyListBimonad()
    }
    
    public static func foldable() -> NonEmptyListFoldable {
        return NonEmptyListFoldable()
    }
    
    public static func traverse() -> NonEmptyListTraverse {
        return NonEmptyListTraverse()
    }
    
    public static func semigroup() -> NonEmptyListSemigroup<A> {
        return NonEmptyListSemigroup<A>()
    }
    
    public static func semigroupK() -> NonEmptyListSemigroupK {
        return NonEmptyListSemigroupK()
    }
    
    public static func eq<EqA>(_ eqa : EqA) -> NonEmptyListEq<A, EqA> {
        return NonEmptyListEq<A, EqA>(eqa)
    }
}

public class NonEmptyListFunctor : Functor {
    public typealias F = NonEmptyListF
    
    public func map<A, B>(_ fa: HK<NonEmptyListF, A>, _ f: @escaping (A) -> B) -> HK<NonEmptyListF, B> {
        return fa.ev().map(f)
    }
}

public class NonEmptyListApplicative : NonEmptyListFunctor, Applicative {
    
    public func pure<A>(_ a: A) -> HK<NonEmptyListF, A> {
        return NonEmptyList.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<NonEmptyListF, A>, _ ff: HK<NonEmptyListF, (A) -> B>) -> HK<NonEmptyListF, B> {
        return fa.ev().ap(ff.ev())
    }
}

public class NonEmptyListMonad : NonEmptyListApplicative, Monad {
    
    public func flatMap<A, B>(_ fa: HK<NonEmptyListF, A>, _ f: @escaping (A) -> HK<NonEmptyListF, B>) -> HK<NonEmptyListF, B> {
        return fa.ev().flatMap({ a in f(a).ev() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<NonEmptyListF, Either<A, B>>) -> HK<NonEmptyListF, B> {
        return NonEmptyList.tailRecM(a, f)
    }
}

public class NonEmptyListBimonad : NonEmptyListMonad, Bimonad {
    public func coflatMap<A, B>(_ fa: HK<NonEmptyListF, A>, _ f: @escaping (HK<NonEmptyListF, A>) -> B) -> HK<NonEmptyListF, B> {
        return fa.ev().coflatMap(f)
    }
    
    public func extract<A>(_ fa: HK<NonEmptyListF, A>) -> A {
        return fa.ev().extract()
    }
}

public class NonEmptyListFoldable : Foldable {
    public typealias F = NonEmptyListF
    
    public func foldL<A, B>(_ fa: HK<NonEmptyListF, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.ev().foldL(b, f)
    }
    
    public func foldR<A, B>(_ fa: HK<NonEmptyListF, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.ev().foldR(b, f)
    }
}

public class NonEmptyListTraverse : NonEmptyListFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: HK<NonEmptyListF, A>, _ f: @escaping (A) -> HK<G, B>, _ applicative: Appl) -> HK<G, HK<NonEmptyListF, B>> where G == Appl.F, Appl : Applicative {
        return fa.ev().traverse(f, applicative)
    }
}

public class NonEmptyListSemigroupK : SemigroupK {
    public typealias F = NonEmptyListF
    
    public func combineK<A>(_ x: HK<NonEmptyListF, A>, _ y: HK<NonEmptyListF, A>) -> HK<NonEmptyListF, A> {
        return x.ev().combineK(y.ev())
    }
}

public class NonEmptyListSemigroup<R> : Semigroup {
    public typealias A = HK<NonEmptyListF, R>
    
    public func combine(_ a: HK<NonEmptyListF, R>, _ b: HK<NonEmptyListF, R>) -> HK<NonEmptyListF, R> {
        return NonEmptyList.ev(a) + NonEmptyList.ev(b)
    }
}

public class NonEmptyListEq<R, EqR> : Eq where EqR : Eq, EqR.A == R {
    public typealias A = HK<NonEmptyListF, R>
    
    private let eqr : EqR
    
    public init(_ eqr : EqR) {
        self.eqr = eqr
    }
    
    public func eqv(_ a: HK<NonEmptyListF, R>, _ b: HK<NonEmptyListF, R>) -> Bool {
        let a = NonEmptyList.ev(a)
        let b = NonEmptyList.ev(b)
        if a.count != b.count {
            return false
        } else {
            return zip(a.all(), b.all()).map{ aa, bb in eqr.eqv(aa, bb) }.reduce(true, and)
        }
    }
}










