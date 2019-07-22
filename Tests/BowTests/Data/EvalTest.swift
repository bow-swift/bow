import XCTest
import BowLaws
import Bow

class EvalTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<ForEval>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForEval>.check()
    }
    
    func testSelectiveLaws() {
        SelectiveLaws<ForEval>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<ForEval>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<ForEval>.check()
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForEval>.check()
    }
    
    func testEquatableKLaws() {
        EquatableKLaws<ForEval, Int>.check()
    }
}
