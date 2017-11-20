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
    var functor : IdFunctor {
        return Id<Int>.functor()
    }
    
    var generator : (Int) -> HK<IdF, Int> {
        return { a in Id<Int>.pure(a) }
    }
    
    var eq : IdEq<Int> {
        return Id<Int>.eq()
    }
    
    func testFunctorLaws() {
        FunctorLaws<IdF>.check(functor: self.functor, generator: self.generator, eq: self.eq)
    }
}
