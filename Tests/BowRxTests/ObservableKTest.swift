import XCTest
import BowLaws
import Bow
@testable import BowRx
import BowRxGenerators
import BowEffectsLaws

extension ObservableKPartial: EquatableK {
    public static func eq<A: Equatable>(
        _ lhs: ObservableKOf<A>,
        _ rhs: ObservableKOf<A>) -> Bool {
        lhs^.value.blockingGet() == rhs^.value.blockingGet()
    }
}

class ObservableKTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<ObservableKPartial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ObservableKPartial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ObservableKPartial>.check()
    }

    func testMonadLaws() {
        MonadLaws<ObservableKPartial>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ObservableKPartial>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ObservableKPartial>.check()
    }
}
