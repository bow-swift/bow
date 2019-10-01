import XCTest
import Bow
import BowLaws

class ArrayTests: XCTestCase {
    func testSemigroupLaws() {
        SemigroupLaws<[Int]>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<[Int]>.check()
    }
}
