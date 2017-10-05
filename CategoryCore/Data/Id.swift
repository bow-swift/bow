//
//  Id.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 4/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class IdF {}

public class Id<A> : HK<IdF, A> {
    private let value : A
    
    public static func pure(_ a : A) -> Id<A> {
        return Id<A>(a)
    }
    
    public static func tailRecM<B>(_ a : (A), _ f : (A) -> Id<Either<A, B>>) -> Id<B> {
        return f(a).value.fold({ left in tailRecM(left, f)},
                               Id<B>.pure)
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
    
    public func traverse<G, B, Appl>(_ f : (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, Id<B>> where Appl : Applicative, Appl.F == G {
        return applicative.map(f(self.value), Id<B>.init)
    }
    
    public func coflatMap<B>(_ f : (Id<A>) -> B) -> Id<B> {
        return self.map{ _ in f(self) }
    }
    
    public func extract() -> A {
        return value
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
}

public class IdFunctor : Functor {
    public typealias F = IdF
    
    public func map<A, B>(_ fa: HK<IdF, A>, _ f: @escaping (A) -> B) -> HK<IdF, B> {
        return (fa as! Id<A>).map(f)
    }
    
    public func lift<A, B>(_ f: @escaping (A) -> B) -> (HK<IdF, A>) -> HK<IdF, B> {
        return { idA in (idA as! Id<A>).map(f) }
    }
}

public class IdApplicative : IdFunctor, Applicative {
    public func pure<A>(_ a: A) -> HK<IdF, A> {
        return Id.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<IdF, A>, _ ff: HK<IdF, (A) -> B>) -> HK<IdF, B> {
        return (fa as! Id<A>).ap(ff as! Id<(A) -> B>)
    }
}

public class IdMonad : IdApplicative, Monad {
    public func flatMap<A, B>(_ fa: HK<IdF, A>, _ f: @escaping (A) -> HK<IdF, B>) -> HK<IdF, B> {
        return (fa as! Id<A>).flatMap(f as! (A) -> Id<B>)
    }
}
