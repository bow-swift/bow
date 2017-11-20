//
//  StringInstancesTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class StringInstancesTest: XCTestCase {
    
    func testEqLaws() {
        EqLaws.check(eq: String.order, generator: id)
    }
    
}
