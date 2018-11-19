import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class StringInstancesTest: XCTestCase {
    
    func testEqLaws() {
        EqLaws.check(eq: String.eq, generator: id)
    }
    
    func testSemigroupLaws() {
        property("String concatenation semigroup") <- forAll { (a : String, b : String, c : String) in
            return SemigroupLaws.check(semigroup: String.concatSemigroup, a: a, b: b, c: c, eq: String.order)
        }
    }
    
    func testMonoidLaws() {
        property("String concatenation monoid") <- forAll { (a : String) in
            return MonoidLaws.check(monoid: String.concatMonoid, a: a, eq: String.order)
        }
    }
}
