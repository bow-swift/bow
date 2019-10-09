import XCTest
import BowLaws
import Bow

class BoolInstancesTest: XCTestCase {

    func testBoolEqLaws() {
        EquatableLaws<Bool>.check()
    }
    
    func testBoolSemiringLaws() {
        SemiringLaws<Bool>.check()
    }

}
