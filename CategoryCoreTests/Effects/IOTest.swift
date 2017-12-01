//
//  IOTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 1/12/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class IOTest: XCTestCase {
    
    let generator = { (a : Int) in IO.pure(a) }
    let eq = IO.eq(Int.order)
    let eqUnit = IO.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IOF>.check(functor: IO<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
}
