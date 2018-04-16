//
//  FunctorFilter.swift
//  Bow
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol FunctorFilter : Functor {
    func mapFilter<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Maybe<B>) -> Kind<F, B>
}

public extension FunctorFilter {
    public func flattenOption<A>(_ fa : Kind<F, Maybe<A>>) -> Kind<F, A> {
        return self.mapFilter(fa, id)
    }
    
    public func filter<A>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Bool) -> Kind<F, A> {
        return self.mapFilter(fa, { a in f(a) ? Maybe.some(a) : Maybe.none() })
    }
}
