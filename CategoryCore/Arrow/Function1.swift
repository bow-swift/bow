//
//  Function1.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 2/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class Function1F {}
public typealias Function1Partial<I> = HK<Function1F, I>

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
    
    public static func tailRecM<A, B>(_ a : A, _ f : @escaping (A) -> HK2<Function1F, I, Either<A, B>>) -> HK2<Function1F, I, B> {
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

public extension Function1 {
    public static func functor() -> Function1Functor<I> {
        return Function1Functor<I>()
    }
    
    public static func applicative() -> Function1Applicative<I> {
        return Function1Applicative<I>()
    }
    
    public static func monad() -> Function1Monad<I> {
        return Function1Monad<I>()
    }
    
    public static func reader() -> Function1MonadReader<I> {
        return Function1MonadReader<I>()
    }
}

public class Function1Functor<I> : Functor {
    public typealias F = Function1Partial<I>
    
    public func map<A, B>(_ fa: HK<HK<Function1F, I>, A>, _ f: @escaping (A) -> B) -> HK<HK<Function1F, I>, B> {
        return (fa as! Function1<I, A>).map(f)
    }
}

public class Function1Applicative<I> : Function1Functor<I>, Applicative {
    public func pure<A>(_ a: A) -> HK<HK<Function1F, I>, A> {
        return Function1<I, A>.pure(a)
    }
    
    public func ap<A, B>(_ fa: HK<HK<Function1F, I>, A>, _ ff: HK<HK<Function1F, I>, (A) -> B>) -> HK<HK<Function1F, I>, B> {
        return (fa as! Function1<I, A>).ap(ff as! Function1<I, (A) -> B>)
    }
}

public class Function1Monad<I> : Function1Applicative<I>, Monad {
    public func flatMap<A, B>(_ fa: HK<HK<Function1F, I>, A>, _ f: @escaping (A) -> HK<HK<Function1F, I>, B>) -> HK<HK<Function1F, I>, B> {
        return (fa as! Function1<I, A>).flatMap({ a in f(a) as! Function1<I, B>})
    }
    
    public func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> HK<HK<Function1F, I>, Either<A, B>>) -> HK<HK<Function1F, I>, B> {
        return Function1<I, A>.tailRecM(a, f)
    }
}

public class Function1MonadReader<I> : Function1Monad<I>, MonadReader {
    public typealias D = I
    
    public func ask() -> HK<HK<Function1F, I>, I> {
        return Function1<I, I>.ask()
    }
    
    public func local<A>(_ f: @escaping (I) -> I, _ fa: HK<HK<Function1F, I>, A>) -> HK<HK<Function1F, I>, A> {
        return (fa as! Function1<I, A>).local(f)
    }
}

























