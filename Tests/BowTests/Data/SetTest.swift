import Bow
import BowLaws
import XCTest

class SetTest: XCTestCase {
    func testSemigroupLaws() {
        SemigroupLaws<Set<Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Set<Int>>.check()
    }
}
