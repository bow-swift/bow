//
//  ConstTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import Bow

class ConstTest: XCTestCase {
    var generator : (Int) -> ConstOf<Int, Int> {
        return { a in Const<Int, Int>.pure(a) }
    }
    
    let eq = Const<Int, Int>.eq(Int.order)
    let eqUnit = Const<Int, ()>.eq(Int.order)
    
    func testEqLaws() {
        EqLaws.check(eq: Const<Int, Int>.eq(Int.order), generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ConstPartial<Int>>.check(functor: Const<Int, Int>.functor(), generator: Const<Int, Int>.pure, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ConstPartial<Int>>.check(applicative: Const<Int, Int>.applicative(Int.sumMonoid), eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("Const semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<ConstOf<Int, Int>>.check(
                semigroup: Const<Int, Int>.semigroup(Int.sumMonoid),
                a: Const<Int, Int>.pure(a),
                b: Const<Int, Int>.pure(b),
                c: Const<Int, Int>.pure(c),
                eq: self.eq)
        }
    }
    
    func testMonoidLaws() {
        property("Const monoid laws") <- forAll { (a : Int) in
            return MonoidLaws<ConstOf<Int, Int>>.check(
                monoid: Const<Int, Int>.monoid(Int.sumMonoid),
                a: Const<Int, Int>.pure(a),
                eq: self.eq)
        }
    }
}
