import XCTest
@testable import BowLaws
import Bow

class IdTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ForId, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForId>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForId>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForId>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForId>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<ForId>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Id<Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForId>.check()
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForId>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForId>.check()
    }
}
