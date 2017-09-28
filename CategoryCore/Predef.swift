//
//  Predef.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 28/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

func id<A>(_ a : A) -> A {
    return a
}

func compose<A, B, C>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> C) -> (A) -> C {
    return { x in g(f(x)) }
}
