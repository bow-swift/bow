//
//  ListKWTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import Bow

class ListKWTest: XCTestCase {
    
    var generator : (Int) -> Kind<ForListKW, Int> {
        return { a in ListKW<Int>.pure(a) }
    }
    
    let eq = ListKW.eq(Int.order)
    let eqUnit = ListKW.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForListKW>.check(functor: ListKW<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForListKW>.check(applicative: ListKW<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForListKW>.check(monad: ListKW<Int>.monad(), eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("ListKW semigroup laws") <- forAll() { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<Kind<ForListKW, Int>>.check(
                semigroup: ListKW<Int>.semigroup(),
                a: ListKW<Int>.pure(a),
                b: ListKW<Int>.pure(b),
                c: ListKW<Int>.pure(c),
                eq: self.eq)
        }
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws.check(semigroupK: ListKW<Int>.semigroupK(), generator: self.generator, eq: self.eq)
    }
    
    func testMonoidLaws() {
        property("ListKW monoid laws") <- forAll() { (a : Int) in
            return MonoidLaws<Kind<ForListKW, Int>>.check(monoid: ListKW<Int>.monoid(), a: ListKW<Int>.pure(a), eq: self.eq)
        }
    }
    
    func testMonoidKLaws() {
        MonoidKLaws.check(monoidK: ListKW<Int>.monoidK(), generator: self.generator, eq: self.eq)
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForListKW>.check(functorFilter: ListKW<Int>.functorFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForListKW>.check(monadFilter: ListKW<Int>.monadFilter(), generator: self.generator, eq: self.eq)
    }
}
