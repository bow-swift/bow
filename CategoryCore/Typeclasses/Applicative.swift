//
//  Applicative.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 28/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol Applicative : Functor {
    func pure<A>(_ a : A) -> HK<F, A>
    func ap<A, B>(_ fa : HK<F, A>, _ ff : HK<F, (A) -> B>) -> HK<F, B>
}

public extension Applicative {
    public func product<A, B>(_ fa : HK<F, A>, _ fb : HK<F, B>) -> HK<F, (A, B)> {
        return self.ap(fb, self.map(fa, { (a : A) in { (b : B) in (a, b) }}))
    }
    
    public func map2<A, B, Z>(_ fa : HK<F, A>, _ fb : HK<F, B>, _ f : @escaping (A, B) -> Z) -> HK<F, Z> {
        return map(product(fa, fb), f)
    }
}

