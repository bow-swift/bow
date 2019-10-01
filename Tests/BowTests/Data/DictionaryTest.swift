import XCTest
import Bow
import BowLaws

class DictionaryTest: XCTestCase {
    func testSemigroupLaws() {
        SemigroupLaws<Dictionary<String, Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Dictionary<String, Int>>.check()
    }
}
