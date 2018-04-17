//
//  EitherTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import Nimble
@testable import Bow

class EitherTest: XCTestCase {
    
    var generator : (Int) -> EitherOf<Int, Int> {
        return { a in Either.pure(a) }
    }
    
    let eq = Either.eq(Int.order, Int.order)
    let eqUnit = Either.eq(Int.order, UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherPartial<Int>>.check(functor: Either<Int, Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
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
    
    func testShowLaws() {
        ShowLaws.check(show: Either.show(), generator: { a in (a % 2 == 0) ? Either<Int, Int>.pure(a) : Either<Int, Int>.left(a) })
    }
    
    func testCheckers() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.isLeft).to(beTrue())
        expect(left.isRight).to(beFalse())
        expect(right.isLeft).to(beFalse())
        expect(right.isRight).to(beTrue())
    }
    
    func testSwap() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(Either.eq(Int.order, String.order).eqv(left.swap(), Either<Int, String>.right("Hello"))).to(beTrue())
        expect(Either.eq(Int.order, String.order).eqv(right.swap(), Either<Int, String>.left(5))).to(beTrue())
    }
    
    func testExists() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        let isPositive = { (x : Int) in x >= 0 }
        
        expect(left.exists(isPositive)).to(beFalse())
        expect(right.exists(isPositive)).to(beTrue())
        expect(right.exists(not <<< isPositive)).to(beFalse())
    }
    
    func testToMaybe() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(Maybe.eq(Int.order).eqv(left.toMaybe(), Maybe<Int>.none())).to(beTrue())
        expect(Maybe.eq(Int.order).eqv(right.toMaybe(), Maybe<Int>.some(5))).to(beTrue())
    }
    
    func testGetOrElse() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.getOrElse(10)).to(be(10))
        expect(right.getOrElse(10)).to(be(5))
    }
    
    func testFilterOrElse() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        let isPositive = { (x : Int) in x >= 0 }
        
        expect(Either.eq(String.order, Int.order).eqv(left.filterOrElse(isPositive, "10"), Either<String, Int>.left("Hello"))).to(beTrue())
        expect(Either.eq(String.order, Int.order).eqv(right.filterOrElse(isPositive, "10"), Either<String, Int>.right(5))).to(beTrue())
        expect(Either.eq(String.order, Int.order).eqv(right.filterOrElse(not <<< isPositive, "10"), Either<String, Int>.left("10"))).to(beTrue())
    }
    
    func testConversionToString() {
        let left = Either<String, Int>.left("Hello")
        let right = Either<String, Int>.right(5)
        
        expect(left.description).to(equal("Left(Hello)"))
        expect(right.description).to(equal("Right(5)"))
    }
}
