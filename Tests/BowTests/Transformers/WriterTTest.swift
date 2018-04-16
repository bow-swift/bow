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
    
    var generator : (Int) -> Kind3<WriterTKind, IdKind, Int, Int> {
        return { a in WriterT.pure(a, Int.sumMonoid, Id<Any>.applicative()) }
    }
    
    let eq = WriterT.eq(Id.eq(Tuple.eq(Int.order, Int.order)))
    let eqUnit = WriterT.eq(Id.eq(Tuple.eq(Int.order, UnitEq())))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<WriterTPartial<IdKind, Int>>.check(functor: WriterT<IdKind, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<WriterTPartial<IdKind, Int>>.check(applicative: WriterT<IdKind, Int, Int>.applicative(Id<Any>.monad(), Int.sumMonoid), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<WriterTPartial<IdKind, Int>>.check(monad: WriterT<IdKind, Int, Int>.monad(Id<Any>.monad(), Int.sumMonoid), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<WriterTPartial<ListKWKind, Int>>.check(
            semigroupK: WriterT<ListKWKind, Int, Int>.semigroupK(ListKW<Int>.semigroupK()),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, ListKW<Int>.applicative()) },
            eq: WriterT<ListKWKind, Int, Int>.eq(ListKW.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<WriterTPartial<ListKWKind, Int>>.check(
            monoidK: WriterT<ListKWKind, Int, Int>.monoidK(ListKW<Int>.monoidK()),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, ListKW<Int>.applicative()) },
            eq: WriterT<ListKWKind, Int, Int>.eq(ListKW.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<WriterTPartial<MaybeKind, Int>>.check(
            functorFilter: WriterT<MaybeKind, Int, Int>.monadFilter(Maybe<Int>.monadFilter(), Int.sumMonoid),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, Maybe<Int>.applicative()) },
            eq: WriterT<MaybeKind, Int, Int>.eq(Maybe.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<WriterTPartial<MaybeKind, Int>>.check(
            monadFilter: WriterT<MaybeKind, Int, Int>.monadFilter(Maybe<Int>.monadFilter(), Int.sumMonoid),
            generator: { (a : Int) in WriterT.pure(a, Int.sumMonoid, Maybe<Int>.applicative()) },
            eq: WriterT<MaybeKind, Int, Int>.eq(Maybe.eq(Tuple.eq(Int.order, Int.order))))
    }
    
    func testMonadWriterLaws() {
        MonadWriterLaws<WriterTPartial<IdKind, Int>, Int>.check(
            monadWriter: WriterT<IdKind, Int, Int>.writer(Id<Int>.monad(), Int.sumMonoid),
            monoid: Int.sumMonoid,
            eq: self.eq,
            eqUnit: WriterT.eq(Id.eq(Tuple.eq(Int.order, UnitEq()))),
            eqTuple: WriterT.eq(Id.eq(Tuple.eq(Int.order, TupleEq(Int.order, Int.order)))))
    }
}
