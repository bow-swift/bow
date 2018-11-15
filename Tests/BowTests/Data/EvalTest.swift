import XCTest
@testable import BowLaws
@testable import Bow

class EvalTest: XCTestCase {
    
    var generator : (Int) -> EvalOf<Int> {
        return { a in Eval.pure(a) }
    }
    
    var eq = Eval.eq(Int.order)
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
}
