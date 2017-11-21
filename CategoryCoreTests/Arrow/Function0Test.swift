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
    
}
