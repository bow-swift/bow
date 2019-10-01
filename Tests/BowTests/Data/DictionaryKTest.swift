import XCTest
import Bow
import BowLaws

class DictionaryKTest: XCTestCase {
    func testSemigroupLaws() {
        SemigroupLaws<DictionaryK<String, Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<DictionaryK<String, Int>>.check()
    }
}
