//
//  ValidatedTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class ValidatedTest: XCTestCase {
    
    var generator : (Int) -> HK2<ValidatedF, Int, Int> {
        return { a in Validated<Int, Int>.pure(a) }
    }
    
    var eq = Validated<Int, Int>.eq(Int.order, Int.order)
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
}
