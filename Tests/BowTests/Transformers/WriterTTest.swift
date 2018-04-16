//
//  WriterTTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class WriterTTest: XCTestCase {
    
    var generator : (Int) -> Kind3<ForWriterT, ForId, Int, Int> {
        return { a in WriterT.pure(a, Int.sumMonoid, Id<Any>.applicative()) }
    }
    
    let eq = WriterT.eq(Id.eq(Tuple.eq(Int.order, Int.order)))
    let eqUnit = WriterT.eq(Id.eq(Tuple.eq(Int.order, UnitEq())))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<WriterTPartial<ForId, Int>>.check(functor: WriterT<ForId, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<WriterTPartial<ForId, Int>>.check(applicative: WriterT<ForId, Int, Int>.applicative(Id<Any>.monad(), Int.sumMonoid), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<WriterTPartial<ForId, Int>>.check(monad: WriterT<ForId, Int, Int>.monad(Id<Any>.monad(), Int.sumMonoid), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<WriterTPartial<ForListK, Int>>.check(
            semigroupK: WriterT<ForListK, Int, Int>.semigroupK(ListK<Int>.semigroupK()),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, ListK<Int>.applicative()) },
            eq: WriterT<ForListK, Int, Int>.eq(ListK.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<WriterTPartial<ForListK, Int>>.check(
            monoidK: WriterT<ForListK, Int, Int>.monoidK(ListK<Int>.monoidK()),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, ListK<Int>.applicative()) },
            eq: WriterT<ForListK, Int, Int>.eq(ListK.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<WriterTPartial<ForMaybe, Int>>.check(
            functorFilter: WriterT<ForMaybe, Int, Int>.monadFilter(Maybe<Int>.monadFilter(), Int.sumMonoid),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, Maybe<Int>.applicative()) },
            eq: WriterT<ForMaybe, Int, Int>.eq(Maybe.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<WriterTPartial<ForMaybe, Int>>.check(
            monadFilter: WriterT<ForMaybe, Int, Int>.monadFilter(Maybe<Int>.monadFilter(), Int.sumMonoid),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, Maybe<Int>.applicative()) },
            eq: WriterT<ForMaybe, Int, Int>.eq(Maybe.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonadWriterLaws() {
        MonadWriterLaws<WriterTPartial<ForId, Int>, Int>.check(
            monadWriter: WriterT<ForId, Int, Int>.writer(Id<Int>.monad(), Int.sumMonoid),
            monoid: Int.sumMonoid,
            eq: self.eq,
            eqUnit: WriterT.eq(Id.eq(Tuple.eq(Int.order, UnitEq()))),
            eqTuple: WriterT.eq(Id.eq(Tuple.eq(Int.order, TupleEq(Int.order, Int.order)))))
    }
}
