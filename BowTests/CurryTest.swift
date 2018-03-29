//
//  CurryTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import Bow

class CurryTest: XCTestCase {
    
    func testCurryingTwoArgumentFunctions() {
        func f(_ a : Int, _ b : Int) -> Int {
            return a + b
        }
        property("Curry and uncurry form an isomorphism") <- forAll() { (a : Int, b : Int) in
            return uncurry(curry(f))(a, b) == f(a, b)
        }
    }
    
    func testCurryingThreeArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int) -> Int {
            return a + b + c
        }
        property("Curry and uncurry form an isomorphism") <- forAll() { (a : Int, b : Int, c : Int) in
            return uncurry(curry(f))(a, b, c) == f(a, b, c)
        }
    }
    
    func testCurryingFourArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int) -> Int {
            return a + b + c + d
        }
        property("Curry and uncurry form an isomorphism") <- forAll() { (a : Int, b : Int, c : Int, d : Int) in
            return uncurry(curry(f))(a, b, c, d) == f(a, b, c, d)
        }
    }
    
    func testCurryingFiveArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int) -> Int {
            return a + b + c + d + e
        }
        property("Curry and uncurry form an isomorphism") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int) in
            return uncurry(curry(f))(a, b, c, d, e) == f(a, b, c, d, e)
        }
    }
    
    func testCurryingSixArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int, _ g : Int) -> Int {
            return a + b + c + d + e + g
        }
        property("Curry and uncurry form an isomorphism") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, g : Int) in
            return uncurry(curry(f))(a, b, c, d, e, g) == f(a, b, c, d, e, g)
        }
    }
    
    func testCurryingSevenArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int, _ g : Int, _ h : Int) -> Int {
            return a + b + c + d + e + g + h
        }
        property("Curry and uncurry form an isomorphism") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, g : Int, h : Int) in
            return uncurry(curry(f))(a, b, c, d, e, g, h) == f(a, b, c, d, e, g, h)
        }
    }
    
}
