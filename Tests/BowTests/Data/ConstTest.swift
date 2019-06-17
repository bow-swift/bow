import XCTest
@testable import BowLaws
import Bow

class ConstTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ConstPartial<Int>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ConstPartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ConstPartial<Int>>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<Const<Int, Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Const<Int, Int>>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Const<Int, Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ConstPartial<Int>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ConstPartial<Int>>.check()
    }
}
