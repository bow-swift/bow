//
//  ApplicativeLaws.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation
import SwiftCheck
@testable import Bow

class ApplicativeLaws<F> {
    
    static func check<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        apIdentity(applicative: applicative, eq: eq)
        homomorphism(applicative: applicative, eq: eq)
        interchange(applicative: applicative, eq: eq)
        mapDerived(applicative: applicative, eq: eq)
        cartesianBuilderMap(applicative: applicative, eq: eq)
        cartesianBuilderTupled(applicative: applicative, eq: eq)
    }
    
    private static func apIdentity<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("ap identity") <- forAll() { (a : Int) in
            return eq.eqv(applicative.ap(applicative.pure(a), applicative.pure(id)),
                          applicative.pure(a))
        }
    }
    
    private static func homomorphism<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("homomorphism") <- forAll() { (a : Int, b : Int) in
            let f : (Int) -> Int = constF(b)
            return eq.eqv(applicative.ap(applicative.pure(a), applicative.pure(f)),
                          applicative.pure(f(a)))
        }
    }
    
    private static func interchange<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("interchange") <- forAll() { (a : Int, b : Int) in
            let fa = applicative.pure(constF(a) as (Int) -> Int)
            return eq.eqv(applicative.ap(applicative.pure(b), fa),
                          applicative.ap(fa, applicative.pure({ (x : (Int) -> Int) in x(a) } )))
        }
    }
    
    private static func mapDerived<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("mad derived") <- forAll() { (a : Int, b : Int) in
            let f : (Int) -> Int = constF(b)
            let fa = applicative.pure(a)
            return eq.eqv(applicative.map(fa, f),
                          applicative.ap(fa, applicative.pure(f)))
            
        }
    }
    
    private static func cartesianBuilderMap<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("cartesian builder map") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int) in
            return eq.eqv(applicative.map(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), applicative.pure(e), applicative.pure(f), { x, y, z, u, v, w in x + y + z - u - v - w }),
                          applicative.pure(a + b + c - d - e - f))
        }
    }
    
    private static func cartesianBuilderTupled<Appl, EqA>(applicative : Appl, eq : EqA) where Appl : Applicative, Appl.F == F, EqA : Eq, EqA.A == Kind<F, Int> {
        property("cartesian builder map") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int) in
            return eq.eqv(applicative.map(applicative.tupled(applicative.pure(a), applicative.pure(b), applicative.pure(c), applicative.pure(d), applicative.pure(e), applicative.pure(f)), { x, y, z, u, v, w in x + y + z - u - v - w }),
                          applicative.pure(a + b + c - d - e - f))
        }
    }
}
