//
//  Yoneda.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 11/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class YonedaF {}
public typealias YonedaPartial<F> = HK<YonedaF, F>

open class Yoneda<F, A> : HK2<YonedaF, F, A> {
    public static func apply<Func>(_ fa : HK<F, A>, _ functor : Func) -> Yoneda<F, A> where Func : Functor, Func.F == F {
        return YonedaFunctor<F, A, Func>(fa, functor)
    }
    
    public static func ev(_ fa : HK2<YonedaF, F, A>) -> Yoneda<F, A> {
        return fa as! Yoneda<F, A>
    }
    
    public func apply<B>(_ f : @escaping (A) -> B) -> HK<F, B> {
        fatalError("Apply must be implemented in subclass")
    }

    public func lower() -> HK<F, A> {
        return apply(id)
    }
    
    public func map<B, Func>(_ ff : @escaping (A) -> B, _ functor : Func) -> Yoneda<F, B> where Func : Functor, Func.F == F {
        return YonedaDefault(self, ff)
    }
    
    public func toCoyoneda() -> Coyoneda<F, A, A> {
        return Coyoneda<F, A, A>.apply(lower(), id)
    }
}

fileprivate class YonedaDefault<F, A, B> : Yoneda<F, B> {
    private let ff : (A) -> B
    private let yoneda : Yoneda<F, A>
    
    init(_ yoneda : Yoneda<F, A>, _ ff : @escaping (A) -> B) {
        self.yoneda = yoneda
        self.ff = ff
    }
    
    override public func apply<C>(_ f: @escaping (B) -> C) -> HK<F, C> {
        return yoneda.apply({ a in f(self.ff(a)) })
    }
}

fileprivate class YonedaFunctor<F, A, Func> : Yoneda<F, A> where Func : Functor, Func.F == F {
    private let fa : HK<F, A>
    private let functor : Func
    
    init(_ fa : HK<F, A>, _ functor : Func) {
        self.fa = fa
        self.functor = functor
    }
    
    override public func apply<B>(_ f: @escaping (A) -> B) -> HK<F, B> {
        return functor.map(fa, f)
    }
}

public extension Yoneda {
    public static func functor<Func>(_ functor : Func) -> YonedaFunctorInstance<F, Func> {
        return YonedaFunctorInstance<F, Func>(functor)
    }
}

public class YonedaFunctorInstance<G, Func> : Functor where Func : Functor, Func.F == G {
    public typealias F = YonedaPartial<G>
    
    private let functor : Func
    
    public init(_ functor : Func) {
        self.functor = functor
    }
    
    public func map<A, B>(_ fa: HK<HK<YonedaF, G>, A>, _ f: @escaping (A) -> B) -> HK<HK<YonedaF, G>, B> {
        return Yoneda.ev(fa).map(f, functor)
    }
}
