import XCTest
@testable import BowLaws
import Bow

class EitherKTest: XCTestCase {
    
    var generator: (Int) -> EitherK<ForId, ForId, Int> {
        return { a in EitherK<ForId, ForId, Int>(Either.right(Id(a))) }
    }

    func testEquatableLaws() {
        EquatableKLaws<EitherKPartial<ForId, ForId>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherKPartial<ForId, ForId>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<EitherKPartial<ForId, ForId>>.check(generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<EitherKPartial<ForId, ForId>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<EitherKPartial<ForId, ForId>>.check(generator: self.generator)
    }
}
