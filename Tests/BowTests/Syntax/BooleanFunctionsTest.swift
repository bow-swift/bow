import XCTest
import SwiftCheck
import Bow
import BowLaws

class BooleanFunctionsTest: XCTestCase {
    
    func testDeMorganLaws() {
        property("¬(a ^ b) == ¬a v ¬b") <~ forAll() { (a : Bool, b : Bool) in
            not(and(a, b)) == or(not(a), not(b))
        }
        
        property("¬(a v b) == ¬a ^ ¬b") <~ forAll() { (a : Bool, b : Bool) in
            not(or(a, b)) == and(not(a), not(b))
        }
    }
    
    func testXor() {
        property("xor(a, b) == (¬a ^ b) v (a ^ ¬b)") <~ forAll() { (a : Bool, b : Bool) in
            xor(a, b) == or(and(not(a), b), and(a, not(b)))
        }
    }
    
    let f0 = { true }
    let f1 = { (a : Int) in a > 0 }
    let f2 = { (a : Int, b : Int) in a > 0 && b > 0 }
    let f3 = { (a : Int, b : Int, c : Int) in a > 0 && b > 0 && c > 0 }
    let f4 = { (a : Int, b : Int, c : Int, d : Int) in a > 0 && b > 0 && c > 0 && d > 0 }
    let f5 = { (a : Int, b : Int, c : Int, d : Int, e : Int) in a > 0 && b > 0 && c > 0 && d > 0 && e > 0 }
    let f6 = { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int) in a > 0 && b > 0 && c > 0 && d > 0 && e > 0 && f > 0 }
    let f7 = { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int) in a > 0 && b > 0 && c > 0 && d > 0 && e > 0 && f > 0 && g > 0 }
    let f8 = { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int, h : Int) in a > 0 && b > 0 && c > 0 && d > 0 && e > 0 && f > 0 && g > 0 && h > 0 }
    let f9 = { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int, h : Int, i : Int) in a > 0 && b > 0 && c > 0 && d > 0 && e > 0 && f > 0 && g > 0 && h > 0 && i > 0 }
    let f10 = { (a : Int, b : Int, c : Int, d : Int, e : Int, f : Int, g : Int, h : Int, i : Int, j : Int) in a > 0 && b > 0 && c > 0 && d > 0 && e > 0 && f > 0 && g > 0 && h > 0 && i > 0 && j > 0 }
    
    func testFunctionComplement() {
        property("Complement isomorphism for 0-ary functions") <~ forAll { (_ : Int) in
            return self.f0() == complement(complement(self.f0))()
        }
        
        property("Complement isomorphism for 1-ary functions") <~ forAll { (x : Int) in
            return self.f1(x) == complement(complement(self.f1))(x)
        }
        
        property("Complement isomorphism for 2-ary functions") <~ forAll { (x : Int) in
            return self.f2(x, x) == complement(complement(self.f2))(x, x)
        }
        
        property("Complement isomorphism for 3-ary functions") <~ forAll { (x : Int) in
            return self.f3(x, x, x) == complement(complement(self.f3))(x, x, x)
        }
        
        property("Complement isomorphism for 4-ary functions") <~ forAll { (x : Int) in
            return self.f4(x, x, x, x) == complement(complement(self.f4))(x, x, x, x)
        }
        
        property("Complement isomorphism for 5-ary functions") <~ forAll { (x : Int) in
            return self.f5(x, x, x, x, x) == complement(complement(self.f5))(x, x, x, x, x)
        }
        
        property("Complement isomorphism for 6-ary functions") <~ forAll { (x : Int) in
            return self.f6(x, x, x, x, x, x) == complement(complement(self.f6))(x, x, x, x, x, x)
        }
        
        property("Complement isomorphism for 7-ary functions") <~ forAll { (x : Int) in
            return self.f7(x, x, x, x, x, x, x) == complement(complement(self.f7))(x, x, x, x, x, x, x)
        }
        
        property("Complement isomorphism for 8-ary functions") <~ forAll { (x : Int) in
            return self.f8(x, x, x, x, x, x, x, x) == complement(complement(self.f8))(x, x, x, x, x, x, x, x)
        }
        
        property("Complement isomorphism for 9-ary functions") <~ forAll { (x : Int) in
            return self.f9(x, x, x, x, x, x, x, x, x) == complement(complement(self.f9))(x, x, x, x, x, x, x, x, x)
        }
        
        property("Complement isomorphism for 10-ary functions") <~ forAll { (x : Int) in
            return self.f10(x, x, x, x, x, x, x, x, x, x) == complement(complement(self.f10))(x, x, x, x, x, x, x, x, x, x)
        }
    }
    
}
