//
//  SemigroupLaws.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import Bow

class SemigroupLaws<A> {
    
    static func check<Semi, EqA>(semigroup : Semi, a : A, b : A, c : A, eq : EqA) -> Bool where Semi : Semigroup, Semi.A == A, EqA : Eq, EqA.A == A {
        return associativity(semigroup: semigroup, a: a, b: b, c: c, eq: eq) && reduction(semigroup: semigroup, a: a, b: b, c: c, eq: eq)
    }
    
    private static func associativity<Semi, EqA>(semigroup : Semi, a : A, b : A, c : A, eq : EqA) -> Bool where Semi : Semigroup, Semi.A == A, EqA : Eq, EqA.A == A {
        return eq.eqv(semigroup.combine(semigroup.combine(a, b), c),
                      semigroup.combine(a, semigroup.combine(b, c)))
    }
    
    private static func reduction<Semi, EqA>(semigroup : Semi, a : A, b : A, c : A, eq : EqA) -> Bool where Semi : Semigroup, Semi.A == A, EqA : Eq, EqA.A == A {
        return eq.eqv(semigroup.combineAll(a, b, c),
                      semigroup.combine(a, semigroup.combine(b, c)))
    }
}
