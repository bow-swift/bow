import XCTest
import Bow
import BowFree
import BowFreeGenerators
import BowLaws

class YonedaTest: XCTestCase {
    func testEquatableKLaws() {
        EquatableKLaws<YonedaPartial<IdPartial>, Int>.check()
    }

    func testHashableKLaws() {
        HashableKLaws<YonedaPartial<IdPartial>, Int>.check()
    }

    func testFunctorLaws() {
        FunctorLaws<YonedaPartial<IdPartial>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<YonedaPartial<IdPartial>>.check()
    }
    
    func testSelectiveLaws() {
        SelectiveLaws<YonedaPartial<IdPartial>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<YonedaPartial<IdPartial>>.check(withStackSafety: false)
    }
    
    func testComonadLaws() {
        ComonadLaws<YonedaPartial<IdPartial>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<YonedaPartial<ArrayKPartial>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<YonedaPartial<ArrayKPartial>>.check()
    }
}
