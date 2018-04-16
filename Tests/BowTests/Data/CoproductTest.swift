//
//  CoproductTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class CoproductTest: XCTestCase {
    
    var generator : (Int) -> Kind3<CoproductKind, IdKind, IdKind, Int> {
        return { a in Coproduct<IdKind, IdKind, Int>(Either.pure(Id.pure(a))) }
    }
    
    var eq = Coproduct.eq(Either.eq(Id.eq(Int.order), Id.eq(Int.order)))
    var eqUnit = Coproduct.eq(Either.eq(Id.eq(UnitEq()), Id.eq(UnitEq())))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<CoproductPartial<IdKind, IdKind>>.check(functor: Coproduct<IdKind, IdKind, Int>.functor(Id<Int>.functor(), Id<Int>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testComonadLaws() {
        ComonadLaws<CoproductPartial<IdKind, IdKind>>.check(comonad: Coproduct<IdKind, IdKind, Int>.comonad(Id<Int>.comonad(), Id<Int>.comonad()), generator: self.generator, eq: self.eq)
    }
}
