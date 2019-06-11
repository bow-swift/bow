import XCTest
@testable import BowLaws
import Bow

class EitherKTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<EitherKPartial<ForId, ForId>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherKPartial<ForId, ForId>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<EitherKPartial<ForId, ForId>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<EitherKPartial<ForId, ForId>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<EitherKPartial<ForId, ForId>>.check()
    }
}
