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
    
    var generator : (Int) -> HK3<WriterTF, IdF, Int, Int> {
        return { a in WriterT.pure(a, Int.sumMonoid, Id<Any>.applicative()) }
    }
    
    let eq = WriterT.eq(Id.eq(Tuple.eq(Int.order, Int.order)))
    let eqUnit = WriterT.eq(Id.eq(Tuple.eq(Int.order, UnitEq())))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<WriterTPartial<IdF, Int>>.check(functor: WriterT<IdF, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<WriterTPartial<IdF, Int>>.check(applicative: WriterT<IdF, Int, Int>.applicative(Id<Any>.monad(), Int.sumMonoid), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<WriterTPartial<IdF, Int>>.check(monad: WriterT<IdF, Int, Int>.monad(Id<Any>.monad(), Int.sumMonoid), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<WriterTPartial<ListKWF, Int>>.check(
            semigroupK: WriterT<ListKWF, Int, Int>.semigroupK(ListKW<Int>.semigroupK()),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, ListKW<Int>.applicative()) },
            eq: WriterT<ListKWF, Int, Int>.eq(ListKW.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<WriterTPartial<ListKWF, Int>>.check(
            monoidK: WriterT<ListKWF, Int, Int>.monoidK(ListKW<Int>.monoidK()),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, ListKW<Int>.applicative()) },
            eq: WriterT<ListKWF, Int, Int>.eq(ListKW.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<WriterTPartial<MaybeF, Int>>.check(
            functorFilter: WriterT<MaybeF, Int, Int>.monadFilter(Maybe<Int>.monadFilter(), Int.sumMonoid),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, Maybe<Int>.applicative()) },
            eq: WriterT<MaybeF, Int, Int>.eq(Maybe.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<WriterTPartial<MaybeF, Int>>.check(
            monadFilter: WriterT<MaybeF, Int, Int>.monadFilter(Maybe<Int>.monadFilter(), Int.sumMonoid),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, Maybe<Int>.applicative()) },
            eq: WriterT<MaybeF, Int, Int>.eq(Maybe.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonadWriterLaws() {
        MonadWriterLaws<WriterTPartial<IdF, Int>, Int>.check(
            monadWriter: WriterT<IdF, Int, Int>.writer(Id<Int>.monad(), Int.sumMonoid),
            monoid: Int.sumMonoid,
            eq: self.eq,
            eqUnit: WriterT.eq(Id.eq(Tuple.eq(Int.order, UnitEq()))),
            eqTuple: WriterT.eq(Id.eq(Tuple.eq(Int.order, TupleEq(Int.order, Int.order)))))
    }
}
