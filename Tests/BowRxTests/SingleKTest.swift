import XCTest
import BowLaws
import Bow
@testable import BowRx
import BowRxGenerators
import BowEffectsLaws

extension ForSingleK: EquatableK {
    public static func eq<A: Equatable>(_ lhs: Kind<ForSingleK, A>, _ rhs: Kind<ForSingleK, A>) -> Bool {
        return SingleK.fix(lhs).value.blockingGet() == SingleK.fix(rhs).value.blockingGet()
    }
}

class SingleKTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<ForSingleK>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForSingleK>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForSingleK>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForSingleK>.check()
    }
}
