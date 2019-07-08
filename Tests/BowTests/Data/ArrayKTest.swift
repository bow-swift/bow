import XCTest
import BowLaws
import Bow

class ArrayKTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ForArrayK, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForArrayK>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForArrayK>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForArrayK>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForArrayK>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<ArrayK<Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ForArrayK>.check()
    }
    
    func testMonoidLaws() {
        MonoidLaws<ArrayK<Int>>.check()
    }
    
    func testMonoidKLaws() {
        MonoidKLaws<ForArrayK>.check()
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForArrayK>.check()
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForArrayK>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForArrayK>.check()
    }
    
    func testMonadCombineLaws() {
        MonadCombineLaws<ForArrayK>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForArrayK>.check()
    }
}
