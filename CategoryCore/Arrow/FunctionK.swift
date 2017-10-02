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

