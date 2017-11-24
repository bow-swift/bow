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

class UnitEq : Eq {
    typealias A = ()
    
    func eqv(_ a: (), _ b: ()) -> Bool {
        return true
    }
}

class MaybeTest: XCTestCase {
    
    var generator : (Int) -> HK<MaybeF, Int> {
        return { a in Maybe.pure(a) }
    }
    
    let eq = Maybe.eq(Int.order)
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<MaybeF>.check(functor: Maybe<Int>.functor(), generator: self.generator, eq: self.eq)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<MaybeF>.check(applicative: Maybe<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<MaybeF>.check(monad: Maybe<Int>.monad(), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<MaybeF, CategoryCore.Unit>.check(applicativeError: Maybe<Int>.monadError(), eq: Maybe.eq(Int.order), eqEither: Maybe.eq(Either.eq(UnitEq(), Int.order)), gen: { () } )
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<MaybeF, CategoryCore.Unit>.check(monadError: Maybe<Int>.monadError(), eq: self.eq, gen: { () })
    }
    
    func testSemigroupLaws() {
        property("Maybe semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<HK<MaybeF, Int>>.check(
                semigroup: Maybe<Int>.semigroup(Int.sumMonoid),
                a: Maybe.pure(a),
                b: Maybe.pure(b),
                c: Maybe.pure(c),
                eq: self.eq)
        }
    }
    
    func testMonoidLaws() {
        property("Maybe monoid laws") <- forAll { (a : Int) in
            return MonoidLaws<HK<MaybeF, Int>>.check(
                monoid: Maybe<Int>.monoid(Int.sumMonoid),
                a: Maybe.pure(a),
                eq: self.eq)
        }
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<MaybeF>.check(functorFilter: Maybe<Int>.functorFilter(), generator: self.generator, eq: self.eq)
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<MaybeF>.check(monadFilter: Maybe<Int>.monadFilter(), generator: self.generator, eq: self.eq)
    }
}
