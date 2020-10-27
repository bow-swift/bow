import XCTest
import BowLaws
import Bow

class Function0Test: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<Function0Partial, Int>.check()
    }

    func testHashableLaws() {
        HashableKLaws<Function0Partial, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<Function0Partial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<Function0Partial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<Function0Partial>.check()
    }

    func testMonadLaws() {
        MonadLaws<Function0Partial>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<Function0Partial>.check()
    }
    
    func testBimonadLaws() {
        BimonadLaws<Function0Partial>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<Function0<String>>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<Function0<String>>.check()
    }
}
