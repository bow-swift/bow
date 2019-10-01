import XCTest
import Bow
import BowLaws

class ArrayTest: XCTestCase {
    func testSemigroupLaws() {
        SemigroupLaws<[Int]>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<[Int]>.check()
    }
}
