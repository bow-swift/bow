//
//  Function0.swift
//  Bow
//
//  Created by Tomás Ruiz López on 2/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class Function0Kind {}

public class Function0<A> : Kind<Function0Kind, A> {
    private let f : () -> A
    
    public static func pure(_ a : A) -> Function0<A> {
        return Function0({ a })
    }
    
    public static func loop<B>(_ a : A, _ f : (A) -> Kind<Function0Kind, Either<A, B>>) -> B {
        let result = (f(a) as! Function0<Either<A, B>>).extract()
        return result.fold({ a in loop(a, f) }, id)
    }
    
    public static func tailRecM<B>(_ a : A, _ f : @escaping (A) -> Kind<Function0Kind, Either<A, B>>) -> Function0<B> {
        return Function0<B>({ loop(a, f) })
    }
    
    public static func fix(_ fa : Kind<Function0Kind, A>) -> Function0<A> {
        return fa.fix()
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
        return Function0<B>(f >>> ff.f())
    }
    
    public func extract() -> A {
        return f()
    }
}

public extension Kind where F == Function0Kind {
    public func fix() -> Function0<A> {
        return self as! Function0<A>
    }
}

public extension Function0 {
    public static func functor() -> Function0Functor {
        return Function0Functor()
    }
    
    public static func applicative() -> Function0Applicative {
        return Function0Applicative()
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
    public typealias F = Function0Kind
    
    public func map<A, B>(_ fa: Kind<Function0Kind, A>, _ f: @escaping (A) -> B) -> Kind<Function0Kind, B> {
        return fa.fix().map(f)
    }
}

public class Function0Applicative : Function0Functor, Applicative {
    public func pure<A>(_ a: A) -> Kind<Function0Applicative.F, A> {
        return Function0.pure(a)
    }
    
    public func ap<A, B>(_ fa: Kind<Function0Applicative.F, A>, _ ff: Kind<Function0Applicative.F, (A) -> B>) -> Kind<Function0Applicative.F, B> {
        return Function0.fix(fa).ap(Function0.fix(ff))
    }
}

public class Function0Monad : Function0Applicative, Monad {
    public func flatMap<A, B>(_ fa: Kind<Function0Kind, A>, _ f: @escaping (A) -> Kind<Function0Kind, B>) -> Kind<Function0Kind, B> {
        return fa.fix().flatMap({ a in f(a).fix() })
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<Function0Kind, Either<A, B>>) -> Kind<Function0Kind, B> {
        return Function0.tailRecM(a, f)
    }
}

public class Function0Bimonad : Function0Monad, Bimonad {
    public func coflatMap<A, B>(_ fa: Kind<Function0Kind, A>, _ f: @escaping (Kind<Function0Kind, A>) -> B) -> Kind<Function0Kind, B> {
        return fa.fix().coflatMap(f)
    }
    
    public func extract<A>(_ fa: Kind<Function0Kind, A>) -> A {
        return fa.fix().extract()
    }
}

public class Function0Eq<B, EqB> : Eq where EqB : Eq, EqB.A == B{
    public typealias A = Kind<Function0Kind, B>
    
    private let eq : EqB
    
    public init(_ eq : EqB) {
        self.eq = eq
    }
    
    public func eqv(_ a: Kind<Function0Kind, B>, _ b: Kind<Function0Kind, B>) -> Bool {
        return eq.eqv(a.fix().extract(), b.fix().extract())
    }
}
