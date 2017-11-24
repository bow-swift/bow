//
//  WriterTTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class WriterTTest: XCTestCase {
    
    var generator : (Int) -> HK3<WriterTF, IdF, Int, Int> {
        return { a in WriterT.pure(a, Int.sumMonoid, Id<Any>.applicative()) }
    }
    
    var eq = WriterT.eq(Id.eq(Tuple.eq(Int.order, Int.order)))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<WriterTPartial<IdF, Int>>.check(functor: WriterT<IdF, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq)
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
}
