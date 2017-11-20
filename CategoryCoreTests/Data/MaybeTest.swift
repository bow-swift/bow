//
//  MaybeTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class MaybeTest: XCTestCase {
    
    var generator : (Int) -> HK<MaybeF, Int> {
        return { a in Maybe.pure(a) }
    }
    
    func testEqLaws() {
        EqLaws.check(eq: Maybe.eq(Int.order), generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<MaybeF>.check(functor: Maybe<Int>.functor(), generator: self.generator, eq: Maybe<Int>.eq(Int.order))
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<MaybeF>.check(applicative: Maybe<Int>.applicative(), eq: Maybe.eq(Int.order))
    }
}
