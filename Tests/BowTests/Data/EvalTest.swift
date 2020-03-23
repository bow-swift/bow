import XCTest
import BowLaws
import Bow

class EvalTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<EvalPartial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EvalPartial>.check()
    }
    
    func testSelectiveLaws() {
        SelectiveLaws<EvalPartial>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<EvalPartial>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<EvalPartial>.check()
    }
    
    func testBimonadLaws() {
        BimonadLaws<EvalPartial>.check()
    }
    
    func testEquatableKLaws() {
        EquatableKLaws<EvalPartial, Int>.check()
    }
}
