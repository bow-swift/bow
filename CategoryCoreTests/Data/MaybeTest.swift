//
//  MaybeTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import CategoryCore

class MaybeTest: XCTestCase {
    
    var generator : (Int) -> HK<MaybeF, Int> {
        return { a in Maybe.pure(a) }
    }
    
    func testEqLaws() {
        EqLaws.check(eq: Maybe.eq(Int.order), generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<MaybeF>.check(functor: Maybe<Int>.functor(), generator: self.generator, eq: Maybe<Int>.eq(Int.order))
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<MaybeF>.check(applicative: Maybe<Int>.applicative(), eq: Maybe.eq(Int.order))
    }
    
    func testMonadLaws() {
        MonadLaws<MaybeF>.check(monad: Maybe<Int>.monad(), eq: Maybe.eq(Int.order))
    }
    
    func testSemigroupLaws() {
        property("Maybe semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<HK<MaybeF, Int>>.check(
                semigroup: Maybe<Int>.semigroup(Int.sumMonoid),
                a: Maybe.pure(a),
                b: Maybe.pure(b),
                c: Maybe.pure(c),
                eq: Maybe.eq(Int.order))
        }
    }
    
    func testMonoidLaws() {
        property("Maybe monoid laws") <- forAll { (a : Int) in
            return MonoidLaws<HK<MaybeF, Int>>.check(
                monoid: Maybe<Int>.monoid(Int.sumMonoid),
                a: Maybe.pure(a),
                eq: Maybe.eq(Int.order))
        }
    }
}
