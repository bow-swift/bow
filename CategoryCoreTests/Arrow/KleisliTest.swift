//
//  KleisliTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class KleisliTest: XCTestCase {
    
    class KleisliPointEq : Eq {
        typealias A = HK3<KleisliF, IdF, Int, Int>
        
        func eqv(_ a: HK<HK<HK<KleisliF, IdF>, Int>, Int>, _ b: HK<HK<HK<KleisliF, IdF>, Int>, Int>) -> Bool {
            let a = Kleisli.ev(a)
            let b = Kleisli.ev(b)
            return a.invoke(1).ev().value == b.invoke(1).ev().value
        }
    }
    
    var generator : (Int) -> HK3<KleisliF, IdF, Int, Int> {
        return { a in Kleisli.pure(a, Id<Int>.applicative()) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<KleisliPartial<IdF, Int>>.check(functor: Kleisli<IdF, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: KleisliPointEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<KleisliPartial<IdF, Int>>.check(applicative: Kleisli<IdF, Int, Int>.applicative(Id<Any>.applicative()), eq: KleisliPointEq())
    }
}
