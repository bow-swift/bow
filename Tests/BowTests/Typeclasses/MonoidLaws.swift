//
//  MonoidLaws.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
@testable import Bow

class MonoidLaws<A> {
    
    static func check<Mono, EqA>(monoid : Mono, a : A, eq : EqA) -> Bool where Mono : Monoid, Mono.A == A, EqA : Eq, EqA.A == A {
        return leftIdentity(monoid: monoid, a: a, eq: eq) && rightIdentity(monoid: monoid, a: a, eq: eq)
    }
    
    private static func leftIdentity<Mono, EqA>(monoid : Mono, a : A, eq : EqA) -> Bool where Mono : Monoid, Mono.A == A, EqA : Eq, EqA.A == A {
        return eq.eqv(monoid.combine(monoid.empty, a), a)
    }
    
    private static func rightIdentity<Mono, EqA>(monoid : Mono, a : A, eq : EqA) -> Bool where Mono : Monoid, Mono.A == A, EqA : Eq, EqA.A == A {
        return eq.eqv(monoid.combine(a, monoid.empty), a)
    }
}
