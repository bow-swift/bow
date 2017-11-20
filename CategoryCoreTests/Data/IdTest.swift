//
//  IdTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import CategoryCore

class IdTest: XCTestCase {
    var generator : (Int) -> HK<IdF, Int> {
        return { a in Id<Int>.pure(a) }
    }
    
    func testEqLaws() {
        EqLaws<HK<IdF, Int>>.check(eq: Id<Int>.eq(Int.order), generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IdF>.check(functor: Id<Int>.functor(), generator: self.generator, eq: Id<Int>.eq(Int.order))
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IdF>.check(applicative: Id<Int>.applicative(), eq: Id.eq(Int.order))
    }
}
