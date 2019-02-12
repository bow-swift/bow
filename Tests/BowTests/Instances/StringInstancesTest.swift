import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class StringInstancesTest: XCTestCase {
    
    func testEqLaws() {
        EquatableLaws<String>.check()
    }
    
    func testSemigroupLaws() {
        property("String concatenation semigroup") <- forAll { (a: String, b: String, c: String) in
            return SemigroupLaws.check(a: a, b: b, c: c)
        }
    }
    
    func testMonoidLaws() {
        property("String concatenation monoid") <- forAll { (a: String) in
            return MonoidLaws.check(a: a)
        }
    }
}
