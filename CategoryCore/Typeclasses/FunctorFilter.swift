//
//  FunctorFilter.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol FunctorFilter : Functor {
    func mapFilter<A, B>(_ fa : HK<F, A>, _ f : (A) -> B?) -> HK<F, B>
}

public extension FunctorFilter {
    public func flattenOption<A>(_ fa : HK<F, A?>) -> HK<F, A> {
        return self.mapFilter(fa, id)
    }
    
    public func filter<A>(_ fa : HK<F, A>, _ f : (A) -> Bool) -> HK<F, A> {
        return self.mapFilter(fa, { a in f(a) ? a : nil })
    }
}
