//
//  EqLaws.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import CategoryCore

class EqLaws<F, A> where A : Arbitrary {
    
    static func check<EqF>(eq : EqF, generator : @escaping (A) -> F) where EqF : Eq, EqF.A == F {
        identityInEquality(eq: eq, generator: generator)
        commutativityInEquality(eq: eq, generator: generator)
    }
    
    private static func identityInEquality<EqF>(eq : EqF, generator : @escaping (A) -> F) where EqF : Eq, EqF.A == F {
        property("Identity: Every object is equal to itself") <- forAll() { (a : A) in
            let fa = generator(a)
            return eq.eqv(fa, fa)
        }
    }
    
    private static func commutativityInEquality<EqF>(eq : EqF, generator : @escaping (A) -> F) where EqF : Eq, EqF.A == F {
        property("Equality is commutative") <- forAll() { (a : A, b : A) in
            let fa = generator(a)
            let fb = generator(b)
            return eq.eqv(fa, fb) == eq.eqv(fb, fa)
        }
    }
}
