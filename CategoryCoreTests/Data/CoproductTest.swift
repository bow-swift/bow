//
//  CoproductTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class CoproductTest: XCTestCase {
    
    var generator : (Int) -> HK3<CoproductF, IdF, IdF, Int> {
        return { a in Coproduct<IdF, IdF, Int>(Either.pure(Id.pure(a))) }
    }
    
    var eq = Coproduct.eq(Either.eq(Id.eq(Int.order), Id.eq(Int.order)))
    var eqUnit = Coproduct.eq(Either.eq(Id.eq(UnitEq()), Id.eq(UnitEq())))
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<CoproductPartial<IdF, IdF>>.check(functor: Coproduct<IdF, IdF, Int>.functor(Id<Int>.functor(), Id<Int>.functor()), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testComonadLaws() {
        ComonadLaws<CoproductPartial<IdF, IdF>>.check(comonad: Coproduct<IdF, IdF, Int>.comonad(Id<Int>.comonad(), Id<Int>.comonad()), generator: self.generator, eq: self.eq)
    }
}
