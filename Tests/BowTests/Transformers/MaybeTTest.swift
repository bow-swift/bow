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
    
    var generator : (Int) -> Kind2<MaybeTKind, IdKind, Int> {
        return { a in MaybeT<IdKind, Int>.pure(a, Id<Any>.applicative()) }
    }
    
    let eq = MaybeT.eq(Id.eq(Maybe.eq(Int.order)), Id<Any>.functor())
    let eqUnit = MaybeT.eq(Id.eq(Maybe.eq(UnitEq())), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<MaybeTPartial<IdKind>>.check(functor: MaybeT<IdKind, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<MaybeTPartial<IdKind>>.check(applicative: MaybeT<IdKind, Int>.applicative(Id<Any>.monad()), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<MaybeTPartial<IdKind>>.check(monad: MaybeT<IdKind, Int>.monad(Id<Any>.monad()), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<MaybeTPartial<IdKind>>.check(semigroupK: MaybeT<IdKind, Int>.semigroupK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<MaybeTPartial<IdKind>>.check(monoidK: MaybeT<IdKind, Int>.monoidK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<MaybeTPartial<IdKind>>.check(functorFilter: MaybeT<IdKind, Int>.functorFilter(Id<Any>.functor()), generator: self.generator, eq: self.eq)
    }
}
