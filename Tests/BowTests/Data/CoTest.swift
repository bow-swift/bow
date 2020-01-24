import XCTest
import BowLaws
import Bow
import BowGenerators

extension CoTPartial: EquatableK where W == ForId, M == ForId {
    public static func eq<A>(_ lhs: Kind<CoTPartial<W, M>, A>, _ rhs: Kind<CoTPartial<W, M>, A>) -> Bool where A : Equatable {
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
