import XCTest
import BowLaws
import Bow
import BowGenerators
import SwiftCheck

class EitherKTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<EitherKPartial<ForId, ForId>, Int>.check()
    }

    func testHashableLaws() {
        HashableKLaws<EitherKPartial<ForId, ForId>, Int>.check()
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
