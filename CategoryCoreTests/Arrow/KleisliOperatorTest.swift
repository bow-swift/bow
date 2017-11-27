//
//  KleisliOperatorTest.swift
//  CategoryCoreTests
//
//  Created by Tomás Ruiz López on 27/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import Nimble
@testable import CategoryCore

class KleisliOperatorTest: XCTestCase {
    
    func testKleisliForFunction0() {
        let f = { (x : Int) in Function0({ x }) }
        let g = { (x : Int) in Function0({ 2 * x }) }
        expect((f >=> g)(5).invoke()).to(be(10))
    }
    
    func testKleisliForFunction1() {
        let f = { (x : Int) in Function1<Int, Int>({ _ in x }) }
        let g = { (x : Int) in Function1<Int, Int>({ _ in 2 * x }) }
        expect((f >=> g)(5).invoke(0)).to(be(10))
    }
    
    func testKleisliForEither() {
        let f = { (x : Int) in Either<String, Int>.left("Left") }
        let g = { (x : Int) in Either<String, Int>.right(x) }
        let h = { (x : Int) in Either<String, Int>.right(2 * x) }
        
        expect(Either.eq(String.order, Int.order).eqv((f >=> g)(5), Either.left("Left"))).to(beTrue())
        expect(Either.eq(String.order, Int.order).eqv((g >=> h)(5), Either.right(10))).to(beTrue())
    }
    
    func testKleisliForId() {
        let f = { (x : Int) in Id(x) }
        let g = { (x : Int) in Id(2*x) }
        
        expect(Id.eq(Int.order).eqv((f >=> g)(5), Id(10))).to(beTrue())
    }
    
    func testKleisliForListKW() {
        let f = { (x : Int) in ListKW([x, x + 1]) }
        let g = { (x : Int) in ListKW([2 * x, 3 * x]) }
        
        expect(ListKW.eq(Int.order).eqv((f >=> g)(1), ListKW([2, 3, 4, 6]))).to(beTrue())
    }
    
    func testKleisliForMaybe() {
        let f = { (x : Int) in Maybe<Int>.none() }
        let g = { (x : Int) in Maybe.some(x) }
        let h = { (x : Int) in Maybe.some(2 * x) }
        
        expect(Maybe.eq(Int.order).eqv((f >=> g)(5), Maybe<Int>.none())).to(beTrue())
        expect(Maybe.eq(Int.order).eqv((g >=> h)(5), Maybe<Int>.some(10))).to(beTrue())
    }
    
    func testKleisliForNonEmptyList() {
        let f = { (x : Int) in NonEmptyList(head: x, tail: [x + 1]) }
        let g = { (x : Int) in NonEmptyList(head: 2 * x, tail: [3 * x]) }
        
        expect(NonEmptyList.eq(Int.order).eqv((f >=> g)(1), NonEmptyList(head:2, tail:[3, 4, 6]))).to(beTrue())
    }
    
    func testKleisliForReader() {
        let f = { (x : Int) in Reader({ (_ : String) in x }) }
        let g = { (x : Int) in Reader({ (_ : String) in 2 * x }) }
        
        expect((f >=> g)(5).invoke("Hello").ev().value).to(be(10))
    }
    
    func testKleisliForTry() {
        enum KleisliError : Error { case testError }
        let f = { (x : Int) in Try<Int>.failure(KleisliError.testError) }
        let g = { (x : Int) in Try<Int>.success(x) }
        let h = { (x : Int) in Try<Int>.success(2 * x) }
        
        expect(Try.eq(Int.order).eqv((f >=> g)(5), Try<Int>.failure(KleisliError.testError))).to(beTrue())
        expect(Try.eq(Int.order).eqv((g >=> h)(5), Try<Int>.success(10))).to(beTrue())
    }
}
