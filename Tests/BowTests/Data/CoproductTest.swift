import XCTest
@testable import BowLaws
@testable import Bow

class CoproductTest: XCTestCase {
    
    var generator: (Int) -> Coproduct<ForId, ForId, Int> {
        return { a in Coproduct<ForId, ForId, Int>(Either.right(Id(a))) }
    }

    func testEquatableLaws() {
        EquatableKLaws<CoproductPartial<ForId, ForId>, Int>.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<CoproductPartial<ForId, ForId>>.check(generator: self.generator)
    }
    
    func testComonadLaws() {
        ComonadLaws<CoproductPartial<ForId, ForId>>.check(generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<CoproductPartial<ForId, ForId>>.check(generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<CoproductPartial<ForId, ForId>>.check(generator: self.generator)
    }
}
