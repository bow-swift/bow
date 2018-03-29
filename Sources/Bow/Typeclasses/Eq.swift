//
//  Eq.swift
//  Bow
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol Eq : Typeclass {
    associatedtype A
    
    func eqv(_ a : A, _ b : A) -> Bool
}

public extension Eq {
    public func neqv(_ a : A, _ b : A) -> Bool {
        return !eqv(a, b)
    }
}
