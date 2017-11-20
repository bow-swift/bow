//
//  NumberInstancesTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import CategoryCore

class NumberInstancesTest: XCTestCase {
    
    func testIntEqLaws() {
        EqLaws.check(eq: Int.order, generator: id)
    }
    
    func testInt8EqLaws() {
        EqLaws.check(eq: Int8.order, generator: id)
    }
    
    func testInt16EqLaws() {
        EqLaws.check(eq: Int16.order, generator: id)
    }
    
    func testInt32EqLaws() {
        EqLaws.check(eq: Int32.order, generator: id)
    }
    
    func testInt64EqLaws() {
        EqLaws.check(eq: Int64.order, generator: id)
    }
    
    func testUIntEqLaws() {
        EqLaws.check(eq: Int.order, generator: id)
    }
    
    func testUInt8EqLaws() {
        EqLaws.check(eq: Int8.order, generator: id)
    }
    
    func testUInt16EqLaws() {
        EqLaws.check(eq: Int16.order, generator: id)
    }
    
    func testUInt32EqLaws() {
        EqLaws.check(eq: Int32.order, generator: id)
    }
    
    func testUInt64EqLaws() {
        EqLaws.check(eq: Int64.order, generator: id)
    }
    
    func testFloatEqLaws() {
        EqLaws.check(eq: Float.order, generator: id)
    }
    
    func testDoubleEqLaws() {
        EqLaws.check(eq: Double.order, generator: id)
    }
    
    
}
