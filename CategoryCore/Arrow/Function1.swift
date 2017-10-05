//
//  Function1.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 2/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class Function1F {}

public class Function1<I, O> : HK2<Function1F, I, O> {
    private let f : (I) -> O
    
    public static func ask<I>() -> Function1<I, I> {
        return Function1<I, I>({ (a : I) in a })
    }
    
    public static func pure<I, A>(_ a : A) -> Function1<I, A> {
        return Function1<I, A>({ _ in a })
    }
    
    private static func step<A, B>(_ a : A, _ t : I, _ f : (A) -> HK2<Function1F, I, Either<A, B>>) -> B {
        let af = (f(a) as! Function1<I, Either<A, B>>).f(t)
        return af.fold({ a in step(a, t, f) }, id)
    }
    
    public static func tailRecM<A, B>(_ a : A, _ f : @escaping (A) -> HK2<Function1F, I, Either<A, B>>) -> Function1<I, B> {
        return Function1<I, B>({ t in step(a, t, f) })
    }
    
    public init(_ f : @escaping (I) -> O) {
        self.f = f
    }
    
    public func map<B>(_ g : @escaping (O) -> B) -> Function1<I, B> {
        return Function1<I, B>(self.f >> g)
    }
    
    public func flatMap<B>(_ g : @escaping (O) -> Function1<I, B>) -> Function1<I, B> {
        let h : (I) -> B = { i in g(self.f(i)).f(i) }
        return Function1<I, B>(h)
    }
    
    public func ap<B>(_ ff : Function1<I, (O) -> B>) -> Function1<I, B> {
        return Function1<I, B>({ i in ff.f(i)(self.f(i)) })
    }
    
    public func local(_ g : @escaping (I) -> I) -> Function1<I, O> {
        return Function1<I, O>(g >> self.f)
    }
}
