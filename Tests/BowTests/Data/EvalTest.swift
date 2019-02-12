import XCTest
@testable import BowLaws
@testable import Bow

class EvalTest: XCTestCase {
    
    var generator: (Int) -> EvalOf<Int> {
        return { a in Eval.pure(a) }
    }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
}
