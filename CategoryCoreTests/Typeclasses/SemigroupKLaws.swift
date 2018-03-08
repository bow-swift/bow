//
//  SemigroupKLaws.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 23/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import CategoryCore

class SemigroupKLaws<F> {
    
    static func check<SemiK, EqF>(semigroupK : SemiK, generator : @escaping (Int) -> HK<F, Int>, eq : EqF) where SemiK : SemigroupK, SemiK.F == F, EqF : Eq, EqF.A == HK<F, Int> {
        associative(semigroupK, generator, eq)
    }
    
    private static func associative<SemiK, EqF>(_ semigroupK : SemiK, _ generator : @escaping (Int) -> HK<F, Int>, _ eq : EqF) where SemiK : SemigroupK, SemiK.F == F, EqF : Eq, EqF.A == HK<F, Int> {
        property("SemigroupK combine is associative") <- forAll { (a : Int, b : Int, c : Int) in
            let fa = generator(a)
            let fb = generator(b)
            let fc = generator(c)
            return eq.eqv(semigroupK.combineK(fa, semigroupK.combineK(fb, fc)),
                          semigroupK.combineK(semigroupK.combineK(fa, fb), fc))
        }
    }
}
