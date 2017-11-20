//
//  TryTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class TryTest: XCTestCase {
    
    var generator : (Int) -> HK<TryF, Int> {
        return { a in Try.pure(a) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<TryF>.check(functor: Try<Int>.functor(), generator: self.generator, eq: Try<Int>.eq(Int.order))
    }
    
}
