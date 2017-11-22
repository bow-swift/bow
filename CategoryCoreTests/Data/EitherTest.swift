//
//  EitherTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class EitherTest: XCTestCase {
    
    var generator : (Int) -> HK2<EitherF, Int, Int> {
        return { a in Either.pure(a) }
    }
    
    func testEqLaws() {
        EqLaws.check(eq: Either<Int, Int>.eq(Int.order, Int.order), generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherPartial<Int>>.check(functor: Either<Int, Int>.functor(), generator: self.generator, eq: Either<Int, Int>.eq(Int.order, Int.order))
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherPartial<Int>>.check(applicative: Either<Int, Int>.applicative(), eq: Either<Int, Int>.eq(Int.order, Int.order))
    }
    
    func testMonadLaws() {
        MonadLaws<EitherPartial<Int>>.check(monad: Either<Int, Int>.monad(), eq: Either<Int, Int>.eq(Int.order, Int.order))
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherPartial<CategoryError>, CategoryError>.check(
            applicativeError: Either<CategoryError, Int>.monadError(),
            eq: Either.eq(CategoryError.eq, Int.order),
            eqEither: Either.eq(CategoryError.eq, Either.eq(CategoryError.eq, Int.order)),
            gen: { CategoryError.arbitrary.generate })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherPartial<CategoryError>>.check(monadError: Either<CategoryError, Int>.monadError(), eq: Either.eq(CategoryError.eq, Int.order))
    }
}
