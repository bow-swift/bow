import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class ConstTest: XCTestCase {
    var generator: (Int) -> Const<Int, Int> {
        return { a in Const<Int, Int>(a) }
    }

    func testEquatableLaws() {
        EquatableKLaws<ConstPartial<Int>, Int>.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ConstPartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ConstPartial<Int>>.check()
    }
    
    func testSemigroupLaws() {
        property("Const semigroup laws") <- forAll { (a: Int, b: Int, c: Int) in
            return SemigroupLaws<Const<Int, Int>>.check(
                a: Const<Int, Int>(a),
                b: Const<Int, Int>(b),
                c: Const<Int, Int>(c))
        }
    }
    
    func testMonoidLaws() {
        property("Const monoid laws") <- forAll { (a: Int) in
            return MonoidLaws<Const<Int, Int>>.check(a: Const<Int, Int>(a))
        }
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Const<Int, Int>>.check(generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ConstPartial<Int>>.check(generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ConstPartial<Int>>.check(generator: self.generator)
    }
}
