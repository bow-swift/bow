import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class OptionTTest: XCTestCase {
    
    var generator : (Int) -> OptionTOf<ForId, Int> {
        return { a in OptionT<ForId, Int>.pure(a) }
    }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<OptionTPartial<ForId>>.check(generator: self.generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<OptionTPartial<ForId>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<OptionTPartial<ForId>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<OptionTPartial<ForId>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<OptionTPartial<ForId>>.check(generator: self.generator)
    }

    func testMonoidKLaws() {
        MonoidKLaws<OptionTPartial<ForId>>.check(generator: self.generator)
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<OptionTPartial<ForId>>.check(generator: self.generator)
    }
}
