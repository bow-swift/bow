//
//  IorTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class IorTest: XCTestCase {
    var generator : (Int) -> HK2<IorF, Int, Int> {
        return { a in Ior<Int, Int>.right(a) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<IorPartial<Int>>.check(functor: Ior<Int, Int>.functor(), generator: self.generator, eq: Ior<Int, Int>.eq(Int.order, Int.order))
    }
    
    func testEqLaws() {
        EqLaws.check(eq: Ior.eq(Int.order, Int.order), generator: self.generator)
    }
}
