//
//  Composed.swift
//  Bow
//
//  Created by Tomás Ruiz López on 15/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public typealias Nested<F, G> = (F, G)

public typealias NestedType<F, G, A> = HK<Nested<F, G>, A>
public typealias UnnestedType<F, G, A> = HK<F, HK<G, A>>

public func unnest<F, G, A>(_ nested : NestedType<F, G, A>) -> HK<F, HK<G, A>> {
    return nested as! UnnestedType<F, G, A>
}

public func nest<F, G, A>(_ unnested : UnnestedType<F, G, A>) -> NestedType<F, G, A> {
    return unnested as! HK<Nested<F, G>, A>
}
