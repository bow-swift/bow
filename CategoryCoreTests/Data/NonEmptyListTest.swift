//
//  NonEmptyListTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
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
    
    func testSemigroupLaws() {
        property("NonEmptyList semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<HK<NonEmptyListF, Int>>.check(
                    semigroup: NonEmptyList<Int>.semigroup(),
                    a: NonEmptyList<Int>.pure(a),
                    b: NonEmptyList<Int>.pure(b),
                    c: NonEmptyList<Int>.pure(c),
                    eq: NonEmptyList<Int>.eq(Int.order))
        }
    }
}
