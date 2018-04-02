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
    var generator : (Int) -> HK3<EitherTF, IdF, Int, Int> {
        return { a in EitherT.pure(a, Id<Int>.applicative()) }
    }
    
    let eq = EitherT.eq(Id.eq(Either.eq(Int.order, Int.order)), Id<Any>.functor())
    let eqUnit = EitherT.eq(Id.eq(Either.eq(Int.order, UnitEq())), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherTPartial<IdF, Int>>.check(
            functor: EitherT<IdF, Int, Int>.functor(Id<Any>.functor()),
            generator: self.generator,
            eq: self.eq,
            eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherTPartial<IdF, Int>>.check(applicative: EitherT<IdF, Int, Int>.applicative(Id<Any>.monad()), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<EitherTPartial<IdF, Int>>.check(monad: EitherT<IdF, Int, Int>.monad(Id<Any>.monad()), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherTPartial<MaybeF, ()>, ()>.check(
            applicativeError: EitherT<MaybeF, (), Int>.monadError(Maybe<Int>.monadError()),
            eq: EitherT<MaybeF, (), Int>.eq(Maybe.eq(Either.eq(UnitEq(), Int.order)), Maybe<Int>.functor()),
            eqEither: EitherT.eq(Maybe.eq(Either.eq(UnitEq(), Either.eq(UnitEq(), Int.order))), Maybe<Any>.functor()),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherTPartial<MaybeF, ()>, ()>.check(
            monadError: EitherT<MaybeF, (), Int>.monadError(Maybe<Int>.monadError()),
            eq: EitherT<MaybeF, (), Int>.eq(Maybe.eq(Either.eq(UnitEq(), Int.order)), Maybe<Int>.functor()),
            gen: { () })
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<EitherTPartial<IdF, Int>>.check(semigroupK: EitherT<IdF, Int, Int>.semigroupK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
}
