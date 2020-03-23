import XCTest
import BowLaws
import Bow

class TryTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<TryPartial, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<TryPartial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<TryPartial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<TryPartial>.check()
    }

    func testMonadLaws() {
        MonadLaws<TryPartial>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Try<Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<TryPartial>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<TryPartial>.check()
    }

    func testFunctorFilterLaws() {
        FunctorFilterLaws<TryPartial>.check()
    }

    func testSemigroupLaws() {
        SemigroupLaws<Try<Int>>.check()
    }

    func testMonoidLaws() {
        MonoidLaws<Try<Int>>.check()
    }
}
