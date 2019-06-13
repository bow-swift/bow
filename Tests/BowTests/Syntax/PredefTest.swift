import XCTest
import SwiftCheck
import Bow

class PredefTest : XCTestCase {
    
    func testIdentity() {
        property("Identity must return the same value") <- forAll() { (a : Int) in
            return id(a) == a
        }
    }
    
    func testConstF() {
        property("constant must create an argument-less function that always return a constant value") <- forAll() { (a : Int) in
            let f : () -> Int = constant(a)
            return f() == a
        }
        
        property("constant must create a one argument function that always return a constant value") <- forAll() { (a : Int, b : Int) in
            let f : (Int) -> Int = constant(a)
            return f(b) == a
        }
        
        property("constant must create a two argument function that always return a constant value") <- forAll() { (a : Int, b : Int, c : Int) in
            let f : (Int, Int) -> Int = constant(a)
            return f(b, c) == a
        }
        
        property("constant must create a three argument function that always return a constant value") <- forAll() { (a : Int, b : Int, c : Int, d : Int) in
            let f : (Int, Int, Int) -> Int = constant(a)
            return f(b, c, d) == a
        }
        
        property("constant must create a four argument function that always return a constant value") <- forAll() { (a : Int, b : Int, c : Int, d : Int, e : Int) in
            let f : (Int, Int, Int, Int) -> Int = constant(a)
            return f(b, c, d, e) == a
        }
    }
    
    func testComposition() {
        property("Function composition is equal to applying functions sequentially") <- forAll() { (a : Int, g : ArrowOf<Int, String>) in
            let f = constant(a)
            let x1 = f()
            let x2 = g.getArrow(x1)
            return x2 == (g.getArrow <<< f)()
        }
        
        property("Function composition is equal to applying functions sequentially") <- forAll() { (f : ArrowOf<Int, Int>, g : ArrowOf<Int, String>, x1 : Int) in
            let x2 = f.getArrow(x1)
            let x3 = g.getArrow(x2)
            return x3 == (g.getArrow <<< f.getArrow)(x1)
        }
        
        property("Function composition is equal to applying functions sequentially") <- forAll() { (a : Int, g : ArrowOf<Int, String>) in
            let f = constant(a)
            let x1 = f()
            let x2 = g.getArrow(x1)
            return x2 == compose(g.getArrow, f)()
        }
        
        property("Function composition is equal to applying functions sequentially") <- forAll() { (f : ArrowOf<Int, Int>, g : ArrowOf<Int, String>, x1 : Int) in
            let x2 = f.getArrow(x1)
            let x3 = g.getArrow(x2)
            return x3 == compose(g.getArrow, f.getArrow)(x1)
        }
        
        property("Function composition is associative") <- forAll() { (f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>, h : ArrowOf<Int, Int>, x : Int) in
            
            return ((h.getArrow <<< g.getArrow) <<< f.getArrow)(x) == (h.getArrow <<< (g.getArrow <<< f.getArrow))(x)
        }
    }
}
