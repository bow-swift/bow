//
//  TraverseFilter.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 9/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol TraverseFilter : Traverse, FunctorFilter {
    func traverseFilter<A, B, G, Appl>(_ fa : HK<F, A>, _ f : @escaping (A) -> HK<G, Maybe<B>>, _ applicative : Appl) -> HK<G, HK<F, B>> where Appl : Applicative, Appl.F == G
}

public extension TraverseFilter {
    public func mapFilter<A, B>(_ fa: HK<F, A>, _ f: @escaping (A) -> Maybe<B>) -> HK<F, B> {
        return (traverseFilter(fa, { a in Id<Maybe<B>>.pure(f(a)) }, Id<Maybe<B>>.applicative()) as! Id<HK<F, B>>).extract()
    }
    
    public func filterA<A, G, Appl>(_ fa : HK<F, A>, _ f : @escaping (A) -> HK<G, Bool>, _ applicative : Appl) -> HK<G, HK<F, A>> where Appl : Applicative, Appl.F == G {
        return traverseFilter(fa, { a in applicative.map(f(a), { b in b ? Maybe.some(a) : Maybe.none() }) }, applicative)
    }
    
    public func filter<A>(_ fa : HK<F, A>, _ f : @escaping (A) -> Bool) -> HK<F, A> {
        return (filterA(fa, { a in Id.pure(f(a)) }, Id<A>.applicative()) as! Id<HK<F, A>>).extract()
    }
}
