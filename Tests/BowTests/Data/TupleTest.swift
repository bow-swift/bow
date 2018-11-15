import XCTest
@testable import BowLaws
@testable import Bow

class TupleTest: XCTestCase {
    
    func testEqLaws() {
        EqLaws.check(eq: Tuple<Int, Int>.eq(Int.order, Int.order), generator: { a in (a, a) })
    }
    
}
