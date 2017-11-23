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
    
    let eq = Either.eq(Int.order, Int.order)
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherPartial<Int>>.check(functor: Either<Int, Int>.functor(), generator: self.generator, eq: self.eq)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherPartial<Int>>.check(applicative: Either<Int, Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<EitherPartial<Int>>.check(monad: Either<Int, Int>.monad(), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherPartial<CategoryError>, CategoryError>.check(
            applicativeError: Either<CategoryError, Int>.monadError(),
            eq: Either.eq(CategoryError.eq, Int.order),
            eqEither: Either.eq(CategoryError.eq, Either.eq(CategoryError.eq, Int.order)),
            gen: { CategoryError.arbitrary.generate })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherPartial<CategoryError>, CategoryError>.check(monadError: Either<CategoryError, Int>.monadError(), eq: Either.eq(CategoryError.eq, Int.order), gen: { CategoryError.arbitrary.generate })
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<EitherPartial<Int>>.check(semigroupK: Either<Int, Int>.semigroupK(), generator: self.generator, eq: self.eq)
    }
}
