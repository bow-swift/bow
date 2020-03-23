import XCTest
import BowLaws
import Bow
@testable import BowRx
import BowRxGenerators
import BowEffectsLaws

extension MaybeKPartial: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: MaybeKOf<A>,
        _ rhs: MaybeKOf<A>) -> Bool {
        lhs^.value.blockingGet() == rhs^.value.blockingGet()
    }
}

class MaybeKTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<MaybeKPartial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<MaybeKPartial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<MaybeKPartial>.check()
    }

    func testMonadLaws() {
        MonadLaws<MaybeKPartial>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<MaybeKPartial>.check()
    }
}
