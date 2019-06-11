import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

class ArrayKTest: XCTestCase {
    
    var generator: (Int) -> ArrayKOf<Int> {
        return { a in ArrayK<Int>.pure(a) }
    }

    func testA() {
        let x = ArrayK([1, 2, 3, 4])
        let y = x.map { a in 2 * a }
        XCTAssertEqual(y, ArrayK([2, 4, 6, 8]))
    }

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
