import XCTest
import BowLaws
import Bow
import BowGenerators

extension CoPartial: EquatableK where W == ForId {
    public static func eq<A: Equatable>(_ lhs: CoOf<W, A>, _ rhs: CoOf<W, A>) -> Bool {
        Co<W, A>.pair().zap(Id(id), ga: lhs^) ==
            Co<W, A>.pair().zap(Id(id), ga: rhs^)
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
