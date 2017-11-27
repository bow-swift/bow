//
//  IdTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import CategoryCore

class IdTest: XCTestCase {
    var generator : (Int) -> HK<IdF, Int> {
        return { a in Id<Int>.pure(a) }
    }
    
    let eq = Id<Int>.eq(Int.order)
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IdF>.check(functor: Id<Int>.functor(), generator: self.generator, eq: self.eq)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IdF>.check(applicative: Id<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<IdF>.check(monad: Id<Int>.monad(), eq: self.eq)
    }
    
    func testComonadLaws() {
        ComonadLaws<IdF>.check(comonad: Id<Int>.comonad(), generator: self.generator, eq: self.eq)
    }
}
