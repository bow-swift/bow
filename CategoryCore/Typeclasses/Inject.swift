//
//  Inject.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 9/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol Inject : Typeclass {
    associatedtype F
    associatedtype G
    associatedtype Function where Function : FunctionK, Function.F == F, Function.G == G
    
    func inj() -> Function
}

public extension Inject {
    public func invoke<A>(_ fa : HK<F, A>) -> HK<G, A> {
        return inj().invoke(fa)
    }
}
