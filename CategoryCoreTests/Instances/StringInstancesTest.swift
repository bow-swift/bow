//
//  StringInstancesTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import CategoryCore

class StringInstancesTest: XCTestCase {
    
    func testEqLaws() {
        EqLaws.check(eq: String.order, generator: id)
    }
    
    func testSemigroupLaws() {
        property("String concatenation semigroup") <- forAll { (a : String, b : String, c : String) in
            return SemigroupLaws.check(semigroup: String.concatMonoid, a: a, b: b, c: c, eq: String.order)
        }
        
    }
}
