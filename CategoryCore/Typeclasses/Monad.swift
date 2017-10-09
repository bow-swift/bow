//
//  Monad.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol Monad : Applicative {
    func flatMap<A, B>(_ fa : HK<F, A>, _ f : @escaping (A) -> HK<F, B>) -> HK<F, B>
    func tailRecM<A, B>(_ a : A, _ f : @escaping (A) -> HK<F, Either<A, B>>) -> HK<F, B>
}

public extension Monad {
    public func ap<A, B>(_ fa: HK<F, A>, _ ff: HK<F, (A) -> B>) -> HK<F, B> {
        return self.flatMap(ff, { f in self.map(fa, f) })
    }
    
    public func flatten<A>(_ ffa : HK<F, HK<F, A>>) -> HK<F, A> {
        return self.flatMap(ffa, id)
    }
    
    public func followedBy<A, B>(_ fa : HK<F, A>, _ fb : HK<F, B>) -> HK<F, B> {
        return self.flatMap(fa, { _ in fb })
    }
    
    public func followedByEval<A, B>(_ fa : HK<F, A>, _ fb : Eval<HK<F, B>>) -> HK<F, B> {
        return self.flatMap(fa, { _ in fb.value() })
    }
    
    public func forEffect<A, B>(_ fa : HK<F, A>, _ fb : HK<F, B>) -> HK<F, A> {
        return self.flatMap(fa, { a in self.map(fb, { _ in a })})
    }
    
    public func forEffectEval<A, B>(_ fa : HK<F, A>, _ fb : Eval<HK<F, B>>) -> HK<F, A> {
        return self.flatMap(fa, { a in self.map(fb.value(), constF(a)) })
    }
    
    public func mproduct<A, B>(_ fa : HK<F, A>, _ f : @escaping (A) -> HK<F, B>) -> HK<F, (A, B)> {
        return self.flatMap(fa, { a in self.map(f(a), { b in (a, b) }) })
    }
    
}
