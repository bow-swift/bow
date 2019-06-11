import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

class StringInstancesTest: XCTestCase {
    
    func testEqLaws() {
        EquatableLaws<String>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<String>.check()
    }
    
    func testMonoidLaws() {
        property("String concatenation monoid") <- forAll { (a: String) in
            return MonoidLaws.check(a: a)
        }
    }
}
