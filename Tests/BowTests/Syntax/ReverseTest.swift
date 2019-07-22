import XCTest
import SwiftCheck
import Bow
import BowLaws

class ReverseTest: XCTestCase {

    let f2 = { (p1 : Int, p2: Int) in p1 + p2 }
    let f3 = { (p1 : Int, p2: Int, p3 : Int) in p1 + p2 + p3 }
    let f4 = { (p1 : Int, p2: Int, p3 : Int, p4 : Int) in p1 + p2 + p3 + p4 }
    let f5 = { (p1 : Int, p2: Int, p3 : Int, p4 : Int, p5 : Int) in p1 + p2 + p3 + p4 + p5 }
    let f6 = { (p1 : Int, p2: Int, p3 : Int, p4 : Int, p5 : Int, p6 : Int) in p1 + p2 + p3 + p4 + p5 + p6 }
    let f7 = { (p1 : Int, p2: Int, p3 : Int, p4 : Int, p5 : Int, p6 : Int, p7 : Int) in p1 + p2 + p3 + p4 + p5 + p6 + p7 }
    let f8 = { (p1 : Int, p2: Int, p3 : Int, p4 : Int, p5 : Int, p6 : Int, p7 : Int, p8 : Int) in p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 }
    let f9 = { (p1 : Int, p2: Int, p3 : Int, p4 : Int, p5 : Int, p6 : Int, p7 : Int, p8 : Int, p9 : Int) in p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9 }
    let f10 = { (p1 : Int, p2: Int, p3 : Int, p4 : Int, p5 : Int, p6 : Int, p7 : Int, p8 : Int, p9 : Int, p10 : Int) in p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9 + p10 }
    
    func testReverseFunctions() {
        property("Reverse isomorphism for 2-ary functions") <~ forAll { (x : Int) in
            self.f2(x, x) == reverse(reverse(self.f2))(x, x)
        }
        
        property("Reverse isomorphism for 3-ary functions") <~ forAll { (x : Int) in
            self.f3(x, x, x) == reverse(reverse(self.f3))(x, x, x)
        }
        
        property("Reverse isomorphism for 4-ary functions") <~ forAll { (x : Int) in
            self.f4(x, x, x, x) == reverse(reverse(self.f4))(x, x, x, x)
        }
        
        property("Reverse isomorphism for 5-ary functions") <~ forAll { (x : Int) in
            self.f5(x, x, x, x, x) == reverse(reverse(self.f5))(x, x, x, x, x)
        }
        
        property("Reverse isomorphism for 6-ary functions") <~ forAll { (x : Int) in
            self.f6(x, x, x, x, x, x) == reverse(reverse(self.f6))(x, x, x, x, x, x)
        }
        
        property("Reverse isomorphism for 7-ary functions") <~ forAll { (x : Int) in
            self.f7(x, x, x, x, x, x, x) == reverse(reverse(self.f7))(x, x, x, x, x, x, x)
        }
        
        property("Reverse isomorphism for 8-ary functions") <~ forAll { (x : Int) in
            self.f8(x, x, x, x, x, x, x, x) == reverse(reverse(self.f8))(x, x, x, x, x, x, x, x)
        }
        
        property("Reverse isomorphism for 9-ary functions") <~ forAll { (x : Int) in
            self.f9(x, x, x, x, x, x, x, x, x) == reverse(reverse(self.f9))(x, x, x, x, x, x, x, x, x)
        }
        
        property("Reverse isomorphism for 10-ary functions") <~ forAll { (x : Int) in
            self.f10(x, x, x, x, x, x, x, x, x, x) == reverse(reverse(self.f10))(x, x, x, x, x, x, x, x, x, x)
        }
    }

}
