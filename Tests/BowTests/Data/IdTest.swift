import XCTest
import BowLaws
import Bow

class IdTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<IdPartial, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<IdPartial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<IdPartial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<IdPartial>.check()
    }

    func testMonadLaws() {
        MonadLaws<IdPartial>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<IdPartial>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Id<Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<IdPartial>.check()
    }
    
    func testBimonadLaws() {
        BimonadLaws<IdPartial>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<IdPartial>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<Id<Int>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Id<Int>>.check()
    }
}
