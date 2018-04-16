//
//  EitherTTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class EitherTTest: XCTestCase {
    var generator : (Int) -> Kind3<ForEitherT, ForId, Int, Int> {
        return { a in EitherT.pure(a, Id<Int>.applicative()) }
    }
    
    let eq = EitherT.eq(Id.eq(Either.eq(Int.order, Int.order)), Id<Any>.functor())
    let eqUnit = EitherT.eq(Id.eq(Either.eq(Int.order, UnitEq())), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherTPartial<ForId, Int>>.check(
            functor: EitherT<ForId, Int, Int>.functor(Id<Any>.functor()),
            generator: self.generator,
            eq: self.eq,
            eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherTPartial<ForId, Int>>.check(applicative: EitherT<ForId, Int, Int>.applicative(Id<Any>.monad()), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<EitherTPartial<ForId, Int>>.check(monad: EitherT<ForId, Int, Int>.monad(Id<Any>.monad()), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherTPartial<ForMaybe, ()>, ()>.check(
            applicativeError: EitherT<ForMaybe, (), Int>.monadError(Maybe<Int>.monadError()),
            eq: EitherT<ForMaybe, (), Int>.eq(Maybe.eq(Either.eq(UnitEq(), Int.order)), Maybe<Int>.functor()),
            eqEither: EitherT.eq(Maybe.eq(Either.eq(UnitEq(), Either.eq(UnitEq(), Int.order))), Maybe<Any>.functor()),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherTPartial<ForMaybe, ()>, ()>.check(
            monadError: EitherT<ForMaybe, (), Int>.monadError(Maybe<Int>.monadError()),
            eq: EitherT<ForMaybe, (), Int>.eq(Maybe.eq(Either.eq(UnitEq(), Int.order)), Maybe<Int>.functor()),
            gen: { () })
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<EitherTPartial<ForId, Int>>.check(semigroupK: EitherT<ForId, Int, Int>.semigroupK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
}
