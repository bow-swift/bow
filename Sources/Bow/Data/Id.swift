//
//  Id.swift
//  Bow
//
//  Created by Tomás Ruiz López on 4/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class IdF {}

public class Id<A> : HK<IdF, A> {
    public let value : A
    
    public static func pure(_ a : A) -> Id<A> {
        return Id<A>(a)
    }
    
    public static func tailRecM<B>(_ a : (A), _ f : (A) -> HK<IdF, Either<A, B>>) -> Id<B> {
        return Id<Either<A, B>>.fix(f(a)).value
            .fold({ left in tailRecM(left, f)},
                  Id<B>.pure)
    }
    
    public static func fix(_ fa : HK<IdF, A>) -> Id<A> {
        return fa.fix()
    }
    
    public init(_ value : A) {
        self.value = value
    }
    
    public func map<B>(_ f : (A) -> B) -> Id<B> {
        return Id<B>(f(value))
    }
    
    public func ap<B>(_ ff : Id<(A) -> B>) -> Id<B> {
        return ff.flatMap(map)
    }
    
    public func flatMap<B>(_ f : (A) -> Id<B>) -> Id<B> {
        return f(value)
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return f(b, value)
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return f(value, b)
    }
    
    public func traverse<G, B, Appl>(_ f : (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, HK<IdF, B>> where Appl : Applicative, Appl.F == G {
        return applicative.map(f(self.value), Id<B>.init)
    }
    
    public func coflatMap<B>(_ f : (Id<A>) -> B) -> Id<B> {
        return self.map{ _ in f(self) }
    }
    
    public func extract() -> A {
        return value
    }
}

public extension HK where F == IdF {
    public func fix() -> Id<A> {
        return self as! Id<A>
    }
}

extension Id : CustomStringConvertible {
    public var description : String {
        return "Id(\(value))"
    }
}

extension Id {
    public static func functor() -> IdFunctor {
        return IdFunctor()
    }
    
    public static func applicative() -> IdApplicative {
        return IdApplicative()
    }
    
    public static func monad() -> IdMonad {
        return IdMonad()
    }
    
    public static func comonad() -> IdBimonad {
        return IdBimonad()
    }
    
    public static func bimonad() -> IdBimonad {
        return IdBimonad()
    }
    
    public static func foldable() -> IdFoldable {
        return IdFoldable()
    }
    
    public static func traverse() -> IdTraverse {
        return IdTraverse()
    }

    public static func eq<EqA>(_ eqa : EqA) -> IdEq<A, EqA> {
        return IdEq<A, EqA>(eqa)
    }
}

public class IdFunctor : Functor {
    public typealias F = IdF
    
    public func map<A, B>(_ fa: HK<IdF, A>, _ f: @escaping (A) -> B) -> HK<IdF, B> {
        return fa.fix().map(f)
    }
}

public class IdApplicative : IdFunctor, Applicative {
    public func pure<A>(_ a: A) -> HK<IdF, A> {
        return Id.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<IdF, A>, _ ff: HK<IdF, (A) -> B>) -> HK<IdF, B> {
        return fa.fix().ap(ff.fix())
    }
}

public class IdMonad : IdApplicative, Monad {
    public func flatMap<A, B>(_ fa: HK<IdF, A>, _ f: @escaping (A) -> HK<IdF, B>) -> HK<IdF, B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<IdF, Either<A, B>>) -> HK<IdF, B> {
        return Id.tailRecM(a, f)
    }
}

public class IdBimonad : IdMonad, Bimonad {
    public func coflatMap<A, B>(_ fa: HK<IdF, A>, _ f: @escaping (HK<IdF, A>) -> B) -> HK<IdF, B> {
        return fa.fix().coflatMap(f as (Id<A>) -> B)
    }
    
    public func extract<A>(_ fa: HK<IdF, A>) -> A {
        return fa.fix().extract()
    }
}

public class IdFoldable : Foldable {
    public typealias F = IdF
    
    public func foldL<A, B>(_ fa: HK<IdF, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldL(b, f)
    }
    
    public func foldR<A, B>(_ fa: HK<IdF, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldR(b, f)
    }
}

public class IdTraverse : IdFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: HK<IdF, A>, _ f: @escaping (A) -> HK<G, B>, _ applicative: Appl) -> HK<G, HK<IdF, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

public class IdEq<B, EqB> : Eq where EqB : Eq, EqB.A == B {
    public typealias A = HK<IdF, B>
    
    private let eqb : EqB
    
    public init(_ eqb : EqB) {
        self.eqb = eqb
    }
    
    public func eqv(_ a: HK<IdF, B>, _ b: HK<IdF, B>) -> Bool {
        return eqb.eqv(Id.fix(a).value, Id.fix(b).value)
    }
}
