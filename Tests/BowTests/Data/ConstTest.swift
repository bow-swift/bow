import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

class ConstTest: XCTestCase {
    var generator: (Int) -> Const<Int, Int> {
        return { a in Const<Int, Int>(a) }
    }

    func testEquatableLaws() {
        EquatableKLaws<ConstPartial<Int>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ConstPartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ConstPartial<Int>>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<Const<Int, Int>>.check()
    }
    
    func testMonoidLaws() {
        property("Const monoid laws") <- forAll { (a: Int) in
            return MonoidLaws<Const<Int, Int>>.check(a: Const<Int, Int>(a))
        }
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Const<Int, Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ConstPartial<Int>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ConstPartial<Int>>.check()
    }
}
