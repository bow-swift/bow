//
//  TupleTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class TupleTest: XCTestCase {
    
    func testEqLaws() {
        EqLaws.check(eq: Tuple<Int, Int>.eq(Int.order, Int.order), generator: { a in (a, a) })
    }
    
}
