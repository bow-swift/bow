import XCTest
import BowLaws
import Bow
import BowGenerators

extension CoPartial: EquatableK where W == ForId {
    public static func eq<A: Equatable>(_ lhs: CoOf<W, A>, _ rhs: CoOf<W, A>) -> Bool {
        ForId.pair().zap(Id(id), lhs^) ==
            ForId.pair().zap(Id(id), rhs^)
    }
}

class CoTest: XCTestCase {
    func testFunctorLaws() {
        FunctorLaws<CoPartial<ForId>>.check()
    }

    func testApplicativeLaws() {
        ApplicativeLaws<CoPartial<ForId>>.check()
    }

    func testMonadLaws() {
        MonadLaws<CoPartial<ForId>>.check()
    }
}
