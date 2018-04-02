//
//  Comonad.swift
//  Bow
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol Comonad : Functor {
    func coflatMap<A, B>(_ fa : HK<F, A>, _ f : @escaping (HK<F, A>) -> B) -> HK<F, B>
    func extract<A>(_ fa : HK<F, A>) -> A
}

public extension Comonad {
    public func duplicate<A>(_ fa : HK<F, A>) -> HK<F, HK<F, A>> {
        return coflatMap(fa, id)
    }
}
