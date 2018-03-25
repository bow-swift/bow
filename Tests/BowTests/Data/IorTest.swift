//
//  IorTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class IorTest: XCTestCase {
    var generator : (Int) -> HK2<IorF, Int, Int> {
        return { a in Ior<Int, Int>.right(a) }
    }
    
    let eq = Ior.eq(Int.order, Int.order)
    let eqUnit = Ior.eq(Int.order, UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IorPartial<Int>>.check(functor: Ior<Int, Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IorPartial<Int>>.check(applicative: Ior<Int, Int>.applicative(Int.sumMonoid), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<IorPartial<Int>>.check(monad: Ior<Int, Int>.monad(Int.sumMonoid), eq: self.eq)
    }
}
