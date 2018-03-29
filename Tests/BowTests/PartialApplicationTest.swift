//
//  PartialApplicationTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 20/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
import SwiftCheck
@testable import Bow

class PartialApplicationTest: XCTestCase {
    
    func testPartialApplicationOneArgumentFunctions() {
        func f(_ a : Int) -> Int {
            return a
        }
        
        property("Partially applies one argument") <- forAll() { (a : Int) in
            let g = a |> f
            return g == f(a)
        }
    }
    
    func testPartialApplicationTwoArgumentFunctions() {
        func f(_ a : Int, _ b : Int) -> Int {
            return a + b
        }
        
        property("Partially applies one argument") <- forAll() { (a : Int, b : Int) in
            let g = a |> f
            return g(b) == f(a, b)
        }
    }
    
    func testPartialApplicationThreeArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int) -> Int {
            return a + b + c
        }
        
        property("Partially applies one argument") <- forAll() { (a : Int, b : Int, c : Int) in
            let g = a |> f
            return g(b, c) == f(a, b, c)
        }
    }
    
    func testPartialApplicationFourArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int) -> Int {
            return a + b + c + d
        }
        
        property("Partially applies one argument") <- forAll() { (a : Int, b : Int, c : Int, d : Int) in
            let g = a |> f
            return g(b, c, d) == f(a, b, c, d)
        }
    }
    
    func testPartialApplicationFiveArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int) -> Int {
            return a + b + c + d + e
        }
        
        property("Partially applies one argument") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int) in
            let g = a |> f
            return g(b, c, d, e) == f(a, b, c, d, e)
        }
    }
    
    func testPartialApplicationSixArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int, _ h : Int) -> Int {
            return a + b + c + d + e + h
        }
        
        property("Partially applies one argument") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, h : Int) in
            let g = a |> f
            return g(b, c, d, e, h) == f(a, b, c, d, e, h)
        }
    }
    
    func testPartialApplicationSevenArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int, _ h : Int, _ i : Int) -> Int {
            return a + b + c + d + e + h + i
        }
        
        property("Partially applies one argument") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, h : Int, i : Int) in
            let g = a |> f
            return g(b, c, d, e, h, i) == f(a, b, c, d, e, h, i)
        }
    }
    
    func testPartialApplicationEightArgumentFunctions() {
        func f(_ a : Int, _ b : Int, _ c : Int, _ d : Int, _ e : Int, _ h : Int, _ i : Int, _ j : Int) -> Int {
            return a + b + c + d + e + h + i + j
        }
        
        property("Partially applies one argument") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int, h : Int, i : Int, j : Int) in
            let g = a |> f
            return g(b, c, d, e, h, i, j) == f(a, b, c, d, e, h, i, j)
        }
    }
}
