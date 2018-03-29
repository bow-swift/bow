//
//  Semigroup.swift
//  Bow
//
//  Created by Tomás Ruiz López on 29/9/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public protocol Semigroup : Typeclass {
    associatedtype A
    
    func combine(_ a : A, _ b : A) -> A
}

public extension Semigroup {
    public func combineAll(_ elems : A...) -> A {
        return combineAll(elems)
    }
    
    public func combineAll(_ elems : [A]) -> A {
        return elems[1 ..< elems.count].reduce(elems[0], self.combine)
    }
}
