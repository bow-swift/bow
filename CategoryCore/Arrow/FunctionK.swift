//
//  FunctionK.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 2/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol FunctionK {
    associatedtype F
    associatedtype G
    
    func invoke<A>(_ fa : HK<F, A>) -> HK<G, A>
}

public class IdFunctionK<M> : FunctionK {
    public typealias F = M
    public typealias G = M
    
    public static var id : IdFunctionK<M> {
        return IdFunctionK<M>()
    }
    
    public func invoke<A>(_ fa: HK<M, A>) -> HK<M, A> {
        return fa
    }
}
