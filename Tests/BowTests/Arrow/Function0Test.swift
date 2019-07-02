import XCTest
@testable import BowLaws
import Bow

class Function0Test: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ForFunction0, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForFunction0>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForFunction0>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForFunction0>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForFunction0>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<ForFunction0>.check()
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForFunction0>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<Function0<String>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Function0<String>>.check()
    }
}
