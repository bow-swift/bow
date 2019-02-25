import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

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
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForArrayK>.check(generator: self.generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForArrayK>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<ForArrayK>.check()
    }
    
    func testSemigroupLaws() {
        property("ArrayK semigroup laws") <- forAll() { (a: Int, b: Int, c: Int) in
            return SemigroupLaws<ArrayK<Int>>.check(
                a: ArrayK<Int>([a]),
                b: ArrayK<Int>([b]),
                c: ArrayK<Int>([c]))
        }
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws.check(generator: self.generator)
    }
    
    func testMonoidLaws() {
        property("ArrayK monoid laws") <- forAll() { (a: Int) in
            return MonoidLaws<ArrayK<Int>>.check(a: ArrayK<Int>([a]))
        }
    }
    
    func testMonoidKLaws() {
        MonoidKLaws.check(generator: self.generator)
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<ForArrayK>.check(generator: self.generator)
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<ForArrayK>.check(generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForArrayK>.check(generator: self.generator)
    }
    
    func testMonadCombineLaws() {
        MonadCombineLaws<ForArrayK>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForArrayK>.check(generator: self.generator)
    }
}
