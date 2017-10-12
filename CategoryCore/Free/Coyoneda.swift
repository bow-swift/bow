//
//  Coyoneda.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 12/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class CoyonedaF {}
public typealias AnyFunc = (AnyObject) -> AnyObject

public class Coyoneda<F, P, A> : HK3<CoyonedaF, F, P, A> {
    private let pivot : HK<F, P>
    private let ks : [AnyFunc]
    
    public static func apply(_ fp : HK<F, P>, _ f : @escaping (P) -> A) -> Coyoneda<F, P, A> {
        return unsafeApply(fp, [f as! AnyFunc])
    }
    
    public static func unsafeApply(_ fp : HK<F, P>, _ fs : [AnyFunc]) -> Coyoneda<F, P, A> {
        return Coyoneda<F, P, A>(fp, fs)
    }
    
    public init(_ pivot : HK<F, P>, _ ks : [AnyFunc]) {
        self.pivot = pivot
        self.ks = ks
    }
    
    private func transform() -> (P) -> A {
        return { p in
            let result = self.ks.reduce(p as AnyObject, { current, f in f(current) })
            return result as! A
        }
    }
    
    public func lower<Func>(_ functor : Func) -> HK<F, A> where Func : Functor, Func.F == F {
        return functor.map(pivot, transform())
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Coyoneda<F, P, B> {
        return Coyoneda<F, P, B>(pivot, ks + [f as! AnyFunc])
    }
    
    public func toYoneda<Func>(_ functor : Func) -> Yoneda<F, A> where Func : Functor, Func.F == F {
        return YonedaFromCoyoneda<F, A, Func>(functor)
    }
}

fileprivate class YonedaFromCoyoneda<F, A, Func> : Yoneda<F, A> where Func : Functor, Func.F == F {
    private let functor : Func
    
    public init(_ functor : Func) {
        self.functor = functor
    }
    
    override public func apply<B>(_ f: @escaping (A) -> B) -> HK<F, B> {
        return map(f, functor).lower()
    }
}
