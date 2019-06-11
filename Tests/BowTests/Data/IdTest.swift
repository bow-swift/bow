import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class IdTest: XCTestCase {
    var generator : (Int) -> Id<Int> {
        return { a in Id<Int>(a) }
    }

    func testEquatableLaws() {
        EquatableKLaws<ForId, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForId>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForId>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForId>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForId>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<ForId>.check(generator: self.generator)
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws.check(generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForId>.check(generator: self.generator)
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForId>.check(generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForId>.check(generator: self.generator)
    }
}
