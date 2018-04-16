//
//  NonEmptyListTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import Bow

class NonEmptyListTest: XCTestCase {
    
    var generator : (Int) -> Kind<NonEmptyListKind, Int> {
        return { a in NonEmptyList.pure(a) }
    }
    
    let eq = NonEmptyList.eq(Int.order)
    let eqUnit = NonEmptyList.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<NonEmptyListKind>.check(functor: NonEmptyList<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<NonEmptyListKind>.check(applicative: NonEmptyList<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<NonEmptyListKind>.check(monad: NonEmptyList<Int>.monad(), eq: self.eq)
    }
    
    func testComonadLaws() {
        ComonadLaws<NonEmptyListKind>.check(comonad: NonEmptyList<Int>.comonad(), generator: self.generator, eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("NonEmptyList semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<Kind<NonEmptyListKind, Int>>.check(
                    semigroup: NonEmptyList<Int>.semigroup(),
                    a: NonEmptyList<Int>.pure(a),
                    b: NonEmptyList<Int>.pure(b),
                    c: NonEmptyList<Int>.pure(c),
                    eq: self.eq)
        }
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<NonEmptyListKind>.check(semigroupK: NonEmptyList<Int>.semigroupK(), generator: self.generator, eq: self.eq)
    }
}
