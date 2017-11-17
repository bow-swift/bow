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
    fileprivate let f : () -> A
    
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
        return Function0Instances().map(self, f) as! Function0<B>
    }
    
    public func flatMap<B>(_ f : @escaping (A) -> Function0<B>) -> Function0<B> {
        return Function0Instances().flatMap(self, f) as! Function0<B>
    }
    
    public func coflatMap<B>(_ f : @escaping (Function0<A>) -> B) -> Function0<B> {
        return Function0Instances().coflatMap(self, f as! (HK<Function0F, A>) -> B) as! Function0<B>
    }
    
    public func ap<B>(_ ff : Function0<(A) -> B>) -> Function0<B> {
        return Function0Instances().ap(self, ff) as! Function0<B>
    }
    
    public func extract() -> A {
        return Function0Instances().extract(self)
    }
    
    public static func pure(_ a : A) -> Function0<A> {
        return Function0Instances().pure(a) as! Function0<A>
    }
}

public extension HK where F == Function0F {
    public func ev() -> Function0<A> {
        return self as! Function0<A>
    }
}

public class Function0Instances : Functor, Applicative, Monad, Comonad, Bimonad {
    public typealias F = Function0F
    
    public func map<A, B>(_ fa: HK<Function0F, A>, _ f: @escaping (A) -> B) -> HK<Function0F, B> {
        let funA = fa as! Function0<A>
        return Function0(funA.f >> f)
    }
    
    public func pure<A>(_ a: A) -> HK<Function0Instances.F, A> {
        return Function0({ a })
    }
    
    public func flatMap<A, B>(_ fa: HK<Function0Instances.F, A>, _ f: @escaping (A) -> HK<Function0Instances.F, B>) -> HK<Function0Instances.F, B> {
        let funA = fa as! Function0<A>
        return f(funA.invoke())
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<Function0F, Either<A, B>>) -> HK<Function0F, B> {
        return Function0.tailRecM(a, f)
    }
    
    public func coflatMap<A, B>(_ fa: HK<Function0Instances.F, A>, _ f: @escaping (HK<Function0Instances.F, A>) -> B) -> HK<Function0Instances.F, B> {
        return Function0({ f(fa) })
    }
    
    public func extract<A>(_ fa: HK<Function0Instances.F, A>) -> A {
        return (fa as! Function0<A>).invoke()
    }
}
