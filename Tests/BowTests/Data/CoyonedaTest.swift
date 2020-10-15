import XCTest
import Bow
import BowLaws

extension CoyonedaPartial: EquatableK where F: EquatableK & Functor {
    public static func eq<A: Equatable>(
        _ lhs: CoyonedaOf<F, A>,
        _ rhs: CoyonedaOf<F, A>
    ) -> Bool {
        lhs^.lower() == rhs^.lower()
    }
}

class CoyonedaTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<CoyonedaPartial<IdPartial>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<CoyonedaPartial<IdPartial>>.check()
    }
    
    func testSelectiveLaws() {
        SelectiveLaws<CoyonedaPartial<IdPartial>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<CoyonedaPartial<IdPartial>>.check(withStackSafety: false)
    }
    
    func testComonadLaws() {
        ComonadLaws<CoyonedaPartial<IdPartial>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<CoyonedaPartial<ArrayKPartial>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<CoyonedaPartial<ArrayKPartial>>.check()
    }
}
