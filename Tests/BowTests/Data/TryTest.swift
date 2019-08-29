import XCTest
import BowLaws
import Bow

class TryTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ForTry, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForTry>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForTry>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForTry>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForTry>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Try<Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForTry>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForTry>.check()
    }

    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForTry>.check()
    }

    func testSemigroupLaws() {
        SemigroupLaws<Try<Int>>.check()
    }

    func testMonoidLaws() {
        MonoidLaws<Try<Int>>.check()
    }
}
