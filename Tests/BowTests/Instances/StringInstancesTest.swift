import XCTest
import BowLaws
import Bow

class StringInstancesTest: XCTestCase {
    
    func testEqLaws() {
        EquatableLaws<String>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<String>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<String>.check()
    }
}
