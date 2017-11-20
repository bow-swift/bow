//
//  NonEmptyListTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class NonEmptyListTest: XCTestCase {
    
    var generator : (Int) -> HK<NonEmptyListF, Int> {
        return { a in NonEmptyList.pure(a) }
    }
    
    func testEqLaws() {
        EqLaws.check(eq: NonEmptyList.eq(Int.order), generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<NonEmptyListF>.check(functor: NonEmptyList<Int>.functor(), generator: self.generator, eq: NonEmptyList<Int>.eq(Int.order))
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<NonEmptyListF>.check(applicative: NonEmptyList<Int>.applicative(), eq: NonEmptyList.eq(Int.order))
    }
}
