//
//  MaybeTTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class MaybeTTest: XCTestCase {
    
    var generator : (Int) -> Kind2<MaybeTF, IdF, Int> {
        return { a in MaybeT<IdF, Int>.pure(a, Id<Any>.applicative()) }
    }
    
    let eq = MaybeT.eq(Id.eq(Maybe.eq(Int.order)), Id<Any>.functor())
    let eqUnit = MaybeT.eq(Id.eq(Maybe.eq(UnitEq())), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<MaybeTPartial<IdF>>.check(functor: MaybeT<IdF, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<MaybeTPartial<IdF>>.check(applicative: MaybeT<IdF, Int>.applicative(Id<Any>.monad()), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<MaybeTPartial<IdF>>.check(monad: MaybeT<IdF, Int>.monad(Id<Any>.monad()), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<MaybeTPartial<IdF>>.check(semigroupK: MaybeT<IdF, Int>.semigroupK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<MaybeTPartial<IdF>>.check(monoidK: MaybeT<IdF, Int>.monoidK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<MaybeTPartial<IdF>>.check(functorFilter: MaybeT<IdF, Int>.functorFilter(Id<Any>.functor()), generator: self.generator, eq: self.eq)
    }
}
