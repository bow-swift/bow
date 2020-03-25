import XCTest
import BowLaws
import Bow

extension TracedTPartial: EquatableK where W: EquatableK & Comonad, M: Monoid {
    public static func eq<A: Equatable>(_ lhs: TracedTOf<M, W, A>,
                                        _ rhs: TracedTOf<M, W, A>) -> Bool {
        lhs^.extract() == rhs^.extract()
    }
}

class TracedTTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<TracedPartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<TracedPartial<Int>>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<TracedPartial<Int>>.check()
    }
    
    func testComonadTracedLaws() {
        ComonadTracedLaws<TracedPartial<String>, String>.check()
    }
    
    func testComonadStoreLaws() {
        ComonadStoreLaws<TracedTPartial<Int, StorePartial<Int>>, Int>.check()
    }
}
