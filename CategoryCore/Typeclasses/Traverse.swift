//
//  Traverse.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 9/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol Traverse : Functor, Foldable {
    func traverse<G, A, B, Appl>(_ fa : HK<F, A>, _ f : @escaping (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, HK<F, B>> where Appl : Applicative, Appl.F == G
}

public extension Traverse {
    public func map<A, B>(_ fa: HK<F, A>, _ f: @escaping (A) -> B) -> HK<F, B> {
        return (traverse(fa, { a in Id<B>.pure(f(a)) }, Id<B>.applicative()) as! Id<HK<F, B>>).extract()
    }
    
    public func sequence<Appl, G, A>(_ applicative : Appl, _ fga : HK<F, HK<G, A>>) -> HK<G, HK<F, A>> where Appl : Applicative, Appl.F == G{
        return traverse(fga, id, applicative)
    }
    
    public func flatTraverse<Appl, Mon, G, A, B>(_ fa : HK<F, A>, _ f : @escaping (A) -> HK<G, HK<F, B>>, _ applicative : Appl, _ monad : Mon) -> HK<G, HK<F, B>> where Appl : Applicative, Appl.F == G, Mon : Monad, Mon.F == F {
        return applicative.map(traverse(fa, f, applicative), monad.flatten)
    }
}
