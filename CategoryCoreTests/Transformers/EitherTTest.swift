//
//  EitherTTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class EitherTTest: XCTestCase {
    var generator : (Int) -> HK3<EitherTF, IdF, Int, Int> {
        return { a in EitherT.pure(a, Id<Int>.applicative()) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherTPartial<IdF, Int>>.check(
            functor: EitherT<IdF, Int, Int>.functor(Id<Int>.functor()),
            generator: self.generator,
            eq: EitherT.eq(Id.eq(Either.eq(Int.order, Int.order)), Id<Any>.functor()))
    }
    
}
