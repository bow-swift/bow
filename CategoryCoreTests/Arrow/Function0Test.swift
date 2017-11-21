//
//  Function0Test.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class Function0Test: XCTestCase {
    
    var generator : (Int) -> HK<Function0F, Int> {
        return { a in Function0.pure(a) }
    }
    
    var eq = Function0<Int>.eq(Int.order)
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<Function0F>.check(functor: Function0<Int>.functor(), generator: self.generator, eq: self.eq)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<Function0F>.check(applicative: Function0<Int>.applicative(), eq: self.eq)
    }
}
