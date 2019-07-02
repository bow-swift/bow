import XCTest
@testable import BowLaws
import Bow
@testable import BowRx
import BowRxGenerators
@testable import BowEffectsLaws

extension ForObservableK: EquatableK {
    public static func eq<A: Equatable>(_ lhs: Kind<ForObservableK, A>, _ rhs: Kind<ForObservableK, A>) -> Bool {
        return ObservableK.fix(lhs).value.blockingGet() == ObservableK.fix(rhs).value.blockingGet()
    }
}

class ObservableKTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<ForObservableK>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForObservableK>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForObservableK>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForObservableK>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForObservableK>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForObservableK>.check()
    }
}
