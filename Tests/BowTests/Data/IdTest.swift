//
//  IdTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import Bow

class IdTest: XCTestCase {
    var generator : (Int) -> Kind<IdF, Int> {
        return { a in Id<Int>.pure(a) }
    }
    
    let eq = Id.eq(Int.order)
    let eqUnit = Id.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IdF>.check(functor: Id<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IdF>.check(applicative: Id<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<IdF>.check(monad: Id<Int>.monad(), eq: self.eq)
    }
    
    func testComonadLaws() {
        ComonadLaws<IdF>.check(comonad: Id<Int>.comonad(), generator: self.generator, eq: self.eq)
    }
}
