import XCTest
import SwiftCheck
@testable import Bow

class PredefTest : XCTestCase {
    
    func testIdentity() {
        property("Identity must return the same value") <- forAll() { (a : Int) in
            return id(a) == a
        }
    }
    
    func testConstF() {
        property("ConstF must create an argument-less function that always return a constant value") <- forAll() { (a : Int) in
            let f : () -> Int = constant(a)
            return f() == a
        }
        
        property("ConstF must create a one argument function that always return a constant value") <- forAll() { (a : Int, b : Int) in
            let f : (Int) -> Int = constant(a)
            return f(b) == a
        }
        
        property("ConstF must create a two argument function that always return a constant value") <- forAll() { (a : Int, b : Int, c : Int) in
            let f : (Int, Int) -> Int = constant(a)
            return f(b, c) == a
        }
        
        property("ConstF must create a three argument function that always return a constant value") <- forAll() { (a : Int, b : Int, c : Int, d : Int) in
            let f : (Int, Int, Int) -> Int = constant(a)
            return f(b, c, d) == a
        }
        
        property("ConstF must create a four argument function that always return a constant value") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int) in
            let f : (Int, Int, Int, Int) -> Int = constant(a)
            return f(b, c, d, e) == a
        }
    }
    
    func testComposition() {
        property("Function composition is equal to applying functions sequentially") <- forAll() { (a : Int, b : String) in
            let f = { a }
            let g = { (_ : Int) in b }
            let x1 = f()
            let x2 = g(x1)
            return x2 == (g <<< f)()
        }
        
        property("Function composition is equal to applying functions sequentially") <- forAll() { (a : Int, b : String, x1 : Int) in
            let f = { (_ : Int) in a }
            let g = { (_ : Int) in b }
            let x2 = f(x1)
            let x3 = g(x2)
            return x3 == (g <<< f)(x1)
        }
        
        property("Function composition is equal to applying functions sequentially") <- forAll() { (a : Int, b : String) in
            let f = { a }
            let g = { (_ : Int) in b }
            let x1 = f()
            let x2 = g(x1)
            return x2 == compose(g, f)()
        }
        
        property("Function composition is equal to applying functions sequentially") <- forAll() { (a : Int, b : String, x1 : Int) in
            let f = { (_ : Int) in a }
            let g = { (_ : Int) in b }
            let x2 = f(x1)
            let x3 = g(x2)
            return x3 == compose(g, f)(x1)
        }
        
        property("Function composition is associative") <- forAll() { (a : Int, b : Int, c : Int, x : Int) in
            let f : (Int) -> Int = constant(a)
            let g : (Int) -> Int = constant(b)
            let h : (Int) -> Int = constant(c)
            
            return ((h <<< g) <<< f)(x) == (h <<< (g <<< f))(x)
        }
    }
}
