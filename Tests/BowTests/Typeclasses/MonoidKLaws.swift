//
//  MonoidKLaws.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 24/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import Bow

class MonoidKLaws<F> {
    
    static func check<MonoK, EqF>(monoidK : MonoK, generator : @escaping (Int) -> Kind<F, Int>, eq : EqF) where MonoK : MonoidK, MonoK.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        leftIdentity(monoidK, generator, eq)
        rightIdentity(monoidK, generator, eq)
    }
    
    private static func leftIdentity<MonoK, EqF>(_ monoidK : MonoK, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where MonoK : MonoidK, MonoK.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("MonoidK left identity") <- forAll { (a : Int) in
            let fa = generator(a)
            return eq.eqv(monoidK.combineK(monoidK.emptyK(), fa), fa)
        }
    }
    
    private static func rightIdentity<MonoK, EqF>(_ monoidK : MonoK, _ generator : @escaping (Int) -> Kind<F, Int>, _ eq : EqF) where MonoK : MonoidK, MonoK.F == F, EqF : Eq, EqF.A == Kind<F, Int> {
        property("MonoidK left identity") <- forAll { (a : Int) in
            let fa = generator(a)
            return eq.eqv(monoidK.combineK(fa, monoidK.emptyK()), fa)
        }
    }
}
