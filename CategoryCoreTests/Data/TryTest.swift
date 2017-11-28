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
    
    let eq = Try.eq(Int.order)
    let eqUnit = Try.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: Try.eq(Int.order), generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<TryF>.check(functor: Try<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<TryF>.check(applicative: Try<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<TryF>.check(monad: Try<Int>.monad(), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<TryF, CategoryError>.check(applicativeError: Try<Int>.monadError(), eq: self.eq, eqEither: Try.eq(Either.eq(CategoryError.eq, Int.order)), gen: { CategoryError.arbitrary.generate })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<TryF, CategoryError>.check(monadError: Try<Int>.monadError(), eq: self.eq, gen: { CategoryError.arbitrary.generate })
    }
}
