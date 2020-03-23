import XCTest
import BowLaws
import Bow
@testable import BowRx
import BowRxGenerators
import BowEffectsLaws

extension SingleKPartial: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: SingleKOf<A>,
        _ rhs: SingleKOf<A>) -> Bool {
        lhs^.value.blockingGet() == rhs^.value.blockingGet()
    }
}

class SingleKTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<SingleKPartial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<SingleKPartial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<SingleKPartial>.check()
    }

    func testMonadLaws() {
        MonadLaws<SingleKPartial>.check()
    }
}
