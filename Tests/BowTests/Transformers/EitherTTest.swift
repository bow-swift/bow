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
    var generator : (Int) -> Kind3<EitherTKind, IdKind, Int, Int> {
        return { a in EitherT.pure(a, Id<Int>.applicative()) }
    }
    
    let eq = EitherT.eq(Id.eq(Either.eq(Int.order, Int.order)), Id<Any>.functor())
    let eqUnit = EitherT.eq(Id.eq(Either.eq(Int.order, UnitEq())), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherTPartial<IdKind, Int>>.check(
            functor: EitherT<IdKind, Int, Int>.functor(Id<Any>.functor()),
            generator: self.generator,
            eq: self.eq,
            eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherTPartial<IdKind, Int>>.check(applicative: EitherT<IdKind, Int, Int>.applicative(Id<Any>.monad()), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<EitherTPartial<IdKind, Int>>.check(monad: EitherT<IdKind, Int, Int>.monad(Id<Any>.monad()), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherTPartial<MaybeKind, ()>, ()>.check(
            applicativeError: EitherT<MaybeKind, (), Int>.monadError(Maybe<Int>.monadError()),
            eq: EitherT<MaybeKind, (), Int>.eq(Maybe.eq(Either.eq(UnitEq(), Int.order)), Maybe<Int>.functor()),
            eqEither: EitherT.eq(Maybe.eq(Either.eq(UnitEq(), Either.eq(UnitEq(), Int.order))), Maybe<Any>.functor()),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherTPartial<MaybeKind, ()>, ()>.check(
            monadError: EitherT<MaybeKind, (), Int>.monadError(Maybe<Int>.monadError()),
            eq: EitherT<MaybeKind, (), Int>.eq(Maybe.eq(Either.eq(UnitEq(), Int.order)), Maybe<Int>.functor()),
            gen: { () })
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<EitherTPartial<IdKind, Int>>.check(semigroupK: EitherT<IdKind, Int, Int>.semigroupK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
}
