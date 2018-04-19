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
    var generator : (Int) -> IdOf<Int> {
        return { a in Id<Int>.pure(a) }
    }
    
    let eq = Id.eq(Int.order)
    let eqUnit = Id.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForId>.check(functor: Id<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForId>.check(applicative: Id<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForId>.check(monad: Id<Int>.monad(), eq: self.eq)
    }
    
    func testComonadLaws() {
        ComonadLaws<ForId>.check(comonad: Id<Int>.comonad(), generator: self.generator, eq: self.eq)
    }
    
    func testShowLaws() {
        ShowLaws.check(show: Id.show(), generator: { a in Id.pure(a) })
    }
}
