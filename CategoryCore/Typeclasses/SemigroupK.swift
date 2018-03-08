//
//  SemigroupK.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol SemigroupK : Typeclass {
    associatedtype F
    
    func combineK<A>(_ x : HK<F, A>, _ y : HK<F, A>) -> HK<F, A>
}

public extension SemigroupK {
    public func algebra<B>() -> SemigroupAlgebra<F, B> {
        return SemigroupAlgebra(combineK : self.combineK)
    }
}

public class SemigroupAlgebra<F, B> : Semigroup {
    public typealias A = HK<F, B>
    
    private let combineK : (HK<F, B>, HK<F, B>) -> HK<F, B>
    
    init(combineK : @escaping (HK<F, B>, HK<F, B>) -> HK<F, B>) {
        self.combineK = combineK
    }
    
    public func combine(_ a: HK<F, B>, _ b: HK<F, B>) -> HK<F, B> {
        return combineK(a, b)
    }
}
