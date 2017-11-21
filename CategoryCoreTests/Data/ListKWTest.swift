//
//  ListKWTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import CategoryCore

class ListKWTest: XCTestCase {
    
    var generator : (Int) -> HK<ListKWF, Int> {
        return { a in ListKW<Int>.pure(a) }
    }
    
    func testEqLaws() {
        EqLaws.check(eq: ListKW.eq(Int.order), generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ListKWF>.check(functor: ListKW<Int>.functor(), generator: self.generator, eq: ListKW<Int>.eq(Int.order))
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ListKWF>.check(applicative: ListKW<Int>.applicative(), eq: ListKW<Int>.eq(Int.order))
    }
    
    func testSemigroupLaws() {
        property("ListKW semigroup laws") <- forAll() { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<HK<ListKWF, Int>>.check(
                semigroup: ListKW<Int>.semigroup(),
                a: ListKW<Int>.pure(a),
                b: ListKW<Int>.pure(b),
                c: ListKW<Int>.pure(c),
                eq: ListKW<Int>.eq(Int.order))
        }
    }
    
}
