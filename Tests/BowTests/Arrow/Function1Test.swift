//
//  Function1Test.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class Function1Test: XCTestCase {
    
    class Function1PointEq : Eq {
        typealias A = HK2<Function1F, Int, Int>
        
        func eqv(_ a: HK<HK<Function1F, Int>, Int>, _ b: HK<HK<Function1F, Int>, Int>) -> Bool {
            return Function1.fix(a).invoke(1) == Function1.fix(b).invoke(1)
        }
    }
    
    class Function1UnitPointEq : Eq {
        typealias A = HK2<Function1F, Int, ()>
        
        func eqv(_ a: HK<HK<Function1F, Int>, ()>, _ b: HK<HK<Function1F, Int>, ()>) -> Bool {
            return Function1.fix(a).invoke(1) == Function1.fix(b).invoke(1)
        }
    }
    
    func testFunctorLaws() {
        FunctorLaws<Function1Partial<Int>>.check(functor: Function1<Int, Int>.functor(), generator: { a in Function1<Int, Int>.pure(a) }, eq: Function1PointEq(), eqUnit: Function1UnitPointEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<Function1Partial<Int>>.check(applicative: Function1<Int, Int>.applicative(), eq: Function1PointEq())
    }
    
    func testMonadLaws() {
        MonadLaws<Function1Partial<Int>>.check(monad: Function1<Int, Int>.monad(), eq: Function1PointEq())
    }
}
