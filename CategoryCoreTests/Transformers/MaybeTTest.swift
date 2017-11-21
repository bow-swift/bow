//
//  MaybeTTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class MaybeTTest: XCTestCase {
    
    var generator : (Int) -> HK2<MaybeTF, IdF, Int> {
        return { a in MaybeT<IdF, Int>.pure(a, Id<Any>.applicative()) }
    }
    
    var eq = MaybeT.eq(Id.eq(Maybe.eq(Int.order)), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<MaybeTPartial<IdF>>.check(functor: MaybeT<IdF, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: self.eq)
    }
}
