import XCTest
import SwiftCheck
@testable import Bow

class BoolInstancesTest: XCTestCase {
    
    func testBoolSemigroupLaws() {
        property("And semigroup laws") <- forAll { (a : Bool, b : Bool, c : Bool) in
            return SemigroupLaws.check(semigroup: Bool.andMonoid, a: a, b: b, c: c, eq: Bool.eq)
        }
        
        property("Or semigroup laws") <- forAll { (a : Bool, b : Bool, c : Bool) in
            return SemigroupLaws.check(semigroup: Bool.orMonoid, a: a, b: b, c: c, eq: Bool.eq)
        }
    }
    
    func testBoolMonoidLaws() {
        property("And monoid laws") <- forAll { (a : Bool, b : Bool, c : Bool) in
            return SemigroupLaws.check(semigroup: Bool.andMonoid, a: a, b: b, c: c, eq: Bool.eq)
        }
        
        property("Or monoid laws") <- forAll { (a : Bool, b : Bool, c : Bool) in
            return SemigroupLaws.check(semigroup: Bool.orMonoid, a: a, b: b, c: c, eq: Bool.eq)
        }
    }
    
    func testEqLaws() {
        EqLaws.check(eq: Bool.eq, generator: id)
    }
    
}
