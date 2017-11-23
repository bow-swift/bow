//
//  ValidatedTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class ValidatedTest: XCTestCase {
    
    var generator : (Int) -> HK2<ValidatedF, Int, Int> {
        return { a in Validated<Int, Int>.pure(a) }
    }
    
    let eq = Validated.eq(Int.order, Int.order)
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ValidatedPartial<Int>>.check(functor: Validated<Int, Int>.functor(), generator: self.generator, eq: self.eq)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ValidatedPartial<Int>>.check(applicative: Validated<Int, Int>.applicative(Int.sumMonoid), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ValidatedPartial<Int>>.check(semigroupK: Validated<Int, Int>.semigroupK(Int.sumMonoid), generator: self.generator, eq: self.eq)
    }
}
