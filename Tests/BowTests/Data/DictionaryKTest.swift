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
    
    func testEquatableKLaws() {
        EquatableLaws<DictionaryK<String, Int>>.check()
    }

    func testHashableKLaws() {
        HashableKLaws<DictionaryKPartial<String>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<DictionaryKPartial<String>>.check()
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<DictionaryKPartial<String>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<DictionaryKPartial<String>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<DictionaryKPartial<String>>.check()
    }
}
