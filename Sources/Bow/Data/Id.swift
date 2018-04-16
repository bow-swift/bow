//
//  Id.swift
//  Bow
//
//  Created by Tomás Ruiz López on 4/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class IdF {}

public class Id<A> : Kind<IdF, A> {
    public let value : A
    
    public static func pure(_ a : A) -> Id<A> {
        return Id<A>(a)
    }
    
    public static func tailRecM<B>(_ a : (A), _ f : (A) -> Kind<IdF, Either<A, B>>) -> Id<B> {
        return Id<Either<A, B>>.fix(f(a)).value
            .fold({ left in tailRecM(left, f)},
                  Id<B>.pure)
    }
    
    public static func fix(_ fa : Kind<IdF, A>) -> Id<A> {
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
    
    public func traverse<G, B, Appl>(_ f : (A) -> Kind<G, B>, _ applicative : Appl) -> Kind<G, Kind<IdF, B>> where Appl : Applicative, Appl.F == G {
        return applicative.map(f(self.value), Id<B>.init)
    }
    
    public func coflatMap<B>(_ f : (Id<A>) -> B) -> Id<B> {
        return self.map{ _ in f(self) }
    }
    
    public func extract() -> A {
        return value
    }
}

public extension Kind where F == IdF {
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
    
    public func map<A, B>(_ fa: Kind<IdF, A>, _ f: @escaping (A) -> B) -> Kind<IdF, B> {
        return fa.fix().map(f)
    }
}

public class IdApplicative : IdFunctor, Applicative {
    public func pure<A>(_ a: A) -> Kind<IdF, A> {
        return Id.pure(a)
    }
    
    public func ap<A, B>(_ fa: Kind<IdF, A>, _ ff: Kind<IdF, (A) -> B>) -> Kind<IdF, B> {
        return fa.fix().ap(ff.fix())
    }
}

public class IdMonad : IdApplicative, Monad {
    public func flatMap<A, B>(_ fa: Kind<IdF, A>, _ f: @escaping (A) -> Kind<IdF, B>) -> Kind<IdF, B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<IdF, Either<A, B>>) -> Kind<IdF, B> {
        return Id.tailRecM(a, f)
    }
}

public class IdBimonad : IdMonad, Bimonad {
    public func coflatMap<A, B>(_ fa: Kind<IdF, A>, _ f: @escaping (Kind<IdF, A>) -> B) -> Kind<IdF, B> {
        return fa.fix().coflatMap(f as (Id<A>) -> B)
    }
    
    public func extract<A>(_ fa: Kind<IdF, A>) -> A {
        return fa.fix().extract()
    }
}

public class IdFoldable : Foldable {
    public typealias F = IdF
    
    public func foldL<A, B>(_ fa: Kind<IdF, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return fa.fix().foldL(b, f)
    }
    
    public func foldR<A, B>(_ fa: Kind<IdF, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return fa.fix().foldR(b, f)
    }
}

public class IdTraverse : IdFoldable, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: Kind<IdF, A>, _ f: @escaping (A) -> Kind<G, B>, _ applicative: Appl) -> Kind<G, Kind<IdF, B>> where G == Appl.F, Appl : Applicative {
        return fa.fix().traverse(f, applicative)
    }
}

public class IdEq<B, EqB> : Eq where EqB : Eq, EqB.A == B {
    public typealias A = Kind<IdF, B>
    
    private let eqb : EqB
    
    public init(_ eqb : EqB) {
        self.eqb = eqb
    }
    
    public func eqv(_ a: Kind<IdF, B>, _ b: Kind<IdF, B>) -> Bool {
        return eqb.eqv(Id.fix(a).value, Id.fix(b).value)
    }
}
