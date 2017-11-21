//
//  Function0.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 2/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class Function0F {}

public class Function0<A> : HK<Function0F, A> {
    private let f : () -> A
    
    public static func pure(_ a : A) -> Function0<A> {
        return Function0({ a })
    }
    
    public static func loop<B>(_ a : A, _ f : (A) -> HK<Function0F, Either<A, B>>) -> B {
        let result = (f(a) as! Function0<Either<A, B>>).extract()
        return result.fold({ a in loop(a, f) }, id)
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> HK<Function0F, Either<A, B>>) -> Function0<B> {
        return Function0<B>({ loop(a, f) })
    }
    
    public static func ev(_ fa : HK<Function0F, A>) -> Function0<A> {
        return fa.ev()
    }
    
    public init(_ f : @escaping () -> A) {
        self.f = f
    }
    
    public func invoke() -> A {
        return f()
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Function0<B> {
        return Function0<B>(self.f >>> f)
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> Function0<B>) -> Function0<B> {
        return f(self.f())
    }
    
    public func coflatMap<B>(_ f : @escaping (Function0<A>) -> B) -> Function0<B> {
        return Function0<B>({ f(self) })
    }
    
    public func ap<B>(_ ff : Function0<(A) -> B>) -> Function0<B> {
        return Function0.applicative().ap(self, ff).ev()
    }
    
    public func extract() -> A {
        return f()
    }
}

public extension HK where F == Function0F {
    public func ev() -> Function0<A> {
        return self as! Function0<A>
    }
}

public extension Function0 {
    public static func functor() -> Function0Functor {
        return Function0Functor()
    }
    
    public static func applicative() -> Function0Monad {
        return Function0Monad()
    }
    
    public static func monad() -> Function0Monad {
        return Function0Monad()
    }
    
    public static func comonad() -> Function0Bimonad {
        return Function0Bimonad()
    }
    
    public static func bimonad() -> Function0Bimonad {
        return Function0Bimonad()
    }
    
    public static func eq<EqA>(_ eq : EqA) -> Function0Eq<A, EqA> {
        return Function0Eq<A, EqA>(eq)
    }
}

public class Function0Functor : Functor {
    public typealias F = Function0F
    
    public func map<A, B>(_ fa: HK<Function0F, A>, _ f: @escaping (A) -> B) -> HK<Function0F, B> {
        return fa.ev().map(f)
    }
}

public class Function0Monad : Function0Functor, Monad {
    public func pure<A>(_ a: A) -> HK<F, A> {
        return Function0.pure(a)
    }
    
    public func flatMap<A, B>(_ fa: HK<Function0F, A>, _ f: @escaping (A) -> HK<Function0F, B>) -> HK<Function0F, B> {
        return fa.ev().flatMap({ a in f(a).ev() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<Function0F, Either<A, B>>) -> HK<Function0F, B> {
        return Function0.tailRecM(a, f)
    }
}

public class Function0Bimonad : Function0Monad, Bimonad {
    public func coflatMap<A, B>(_ fa: HK<Function0F, A>, _ f: @escaping (HK<Function0F, A>) -> B) -> HK<Function0F, B> {
        return fa.ev().coflatMap(f)
    }
    
    public func extract<A>(_ fa: HK<Function0F, A>) -> A {
        return fa.ev().extract()
    }
}

public class Function0Eq<B, EqB> : Eq where EqB : Eq, EqB.A == B{
    public typealias A = HK<Function0F, B>
    
    private let eq : EqB
    
    public init(_ eq : EqB) {
        self.eq = eq
    }
    
    public func eqv(_ a: HK<Function0F, B>, _ b: HK<Function0F, B>) -> Bool {
        return eq.eqv(a.ev().extract(), b.ev().extract())
    }
}
