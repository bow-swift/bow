//
//  ConstTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import CategoryCore

class ConstTest: XCTestCase {
    var generator : (Int) -> HK<HK<ConstF, Int>, Int> {
        return { a in Const<Int, Int>.pure(a) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<HK<ConstF, Int>>.check(functor: Const<Int, Int>.functor(), generator: Const<Int, Int>.pure, eq: Const<Int, Int>.eq(Int.order))
    }
    
    func testEqLaws() {
        EqLaws.check(eq: Const<Int, Int>.eq(Int.order), generator: self.generator)
    }
}
