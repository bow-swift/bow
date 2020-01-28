import XCTest
import BowLaws
import Bow
import BowGenerators

extension CoTPartial: EquatableK where W: Applicative & EquatableK, M == ForId {
    public static func eq<A: Equatable>(_ lhs: CoTOf<W, M, A>, _ rhs: CoTOf<W, M, A>) -> Bool {
        W.pair().zap(W.pure(id), lhs^) ==
            W.pair().zap(W.pure(id), rhs^)
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
    
    func testMonadStateLaws() {
        MonadStateLaws<CoPartial<StorePartial<Int>>>.check()
    }
}
