import XCTest
@testable import BowLaws
import Bow
@testable import BowRx
import BowRxGenerators
@testable import BowEffectsLaws

extension ForMaybeK: EquatableK {
    public static func eq<A: Equatable>(_ lhs: Kind<ForMaybeK, A>, _ rhs: Kind<ForMaybeK, A>) -> Bool {
        return MaybeK.fix(lhs).value.blockingGet() == MaybeK.fix(rhs).value.blockingGet()
    }
}

class MaybeKTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<ForMaybeK>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForMaybeK>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForMaybeK>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForMaybeK>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForMaybeK>.check()
    }
}
