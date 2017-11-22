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
    
    var eq = EitherT.eq(Id.eq(Either.eq(Int.order, Int.order)), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherTPartial<IdF, Int>>.check(
            functor: EitherT<IdF, Int, Int>.functor(Id<Any>.functor()),
            generator: self.generator,
            eq: self.eq)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherTPartial<IdF, Int>>.check(applicative: EitherT<IdF, Int, Int>.applicative(Id<Any>.monad()), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<EitherTPartial<IdF, Int>>.check(monad: EitherT<IdF, Int, Int>.monad(Id<Any>.monad()), eq: self.eq)
    }
}
