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
    
    func testSequence() {
        let x: Array<Option<Int>> = [.some(1), .none(), .some(2)]
        XCTAssertEqual(x.sequence()^, .none())
        
        let y: Array<Option<Int>> = [.some(1), .some(2)]
        XCTAssertEqual(y.sequence()^, .some([1, 2]))
    }
}
