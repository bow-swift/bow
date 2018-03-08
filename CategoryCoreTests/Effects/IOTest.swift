//
//  IOTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 1/12/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import CategoryCore

class IOTest: XCTestCase {
    
    class ErrorEq : Eq {
        typealias A = Error
        
        func eqv(_ a: Error, _ b: Error) -> Bool {
            if let a = a as? CategoryError, let b = b as? CategoryError {
                return CategoryError.eq.eqv(a, b)
            } else {
                return false
            }
        }
    }
    
    let generator = { (a : Int) in IO.pure(a) }
    let eq = IO.eq(Int.order, ErrorEq())
    let eqUnit = IO.eq(UnitEq(), ErrorEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<IOF>.check(functor: IO<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IOF>.check(applicative: IO<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<IOF>.check(monad: IO<Int>.monad(), eq: self.eq)
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<IOF, Error>.check(monadError: IO<Int>.monadError(), eq: self.eq, gen: { CategoryError.arbitrary.generate })
    }
    
    func testSemigroupLaws() {
        property("Semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            SemigroupLaws<HK<IOF, Int>>.check(
                semigroup: IO<Int>.semigroup(Int.sumMonoid),
                a: IO.pure(a),
                b: IO.pure(b),
                c: IO.pure(c),
                eq: self.eq)
        }
    }
    
    func testMonoidLaws() {
        property("Monoid laws") <- forAll { (a : Int) in
            MonoidLaws<HK<IOF, Int>>.check(monoid: IO<Int>.monoid(Int.sumMonoid), a: IO.pure(a), eq: self.eq)
        }
    }
    
    func testAsyncContextLaws() {
        AsyncContextLaws<IOF>.check(asyncContext: IO<Int>.asyncContext(), monadError: IO<Int>.monadError(), eq: self.eq, gen : { CategoryError.arbitrary.generate })
    }
}
