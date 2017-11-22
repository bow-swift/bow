//
//  StateTTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import CategoryCore

class StateTTest: XCTestCase {
    
    class StateTUnitEq : Eq {
        public typealias A = HK3<StateTF, IdF, Int, Int>
        
        public func eqv(_ a: HK3<StateTF, IdF, Int, Int>, _ b: HK3<StateTF, IdF, Int, Int>) -> Bool {
            let x = StateT.ev(a).runM(1, Id<Any>.monad()).ev().value
            let y = StateT.ev(b).runM(1, Id<Any>.monad()).ev().value
            return x == y
        }
    }
    
    var generator : (Int) -> HK3<StateTF, IdF, Int, Int> {
        return { a in StateT.lift(Id<Int>.pure(a), Id<Any>.monad()) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<StateTPartial<IdF, Int>>.check(functor: StateT<IdF, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: StateTUnitEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<StateTPartial<IdF, Int>>.check(applicative: StateT<IdF, Int, Int>.applicative(Id<Any>.monad()), eq: StateTUnitEq())
    }
    
    func testMonadLaws() {
        MonadLaws<StateTPartial<IdF, Int>>.check(monad: StateT<IdF, Int, Int>.monad(Id<Any>.monad()), eq: StateTUnitEq())
    }
}
