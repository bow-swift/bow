import XCTest
import BowLaws
import Bow
import BowGenerators

//extension CoPartial: EquatableK where W == ForId {
//    public static func eq<A>(_ lhs: Kind<CoPartial<W>, A>, _ rhs: Kind<CoPartial<W>, A>) -> Bool where A : Equatable {
//        return Co<W, A>.pair().zap(Id({ $0 }), ga: Co.fix(lhs)) == Co<W, A>.pair().zap(Id({ $0 }), ga: Co.fix(rhs))
//    }
//}
//
//class CoTest: XCTestCase {
//    func testFunctorLaws() {
//            FunctorLaws<CoPartial<ForId>>.check()
//    }
//
//    func testApplicativeLaws() {
//        ApplicativeLaws<CoPartial<ForId>>.check()
//    }
//
//    func testMonadLaws() {
//        MonadLaws<CoPartial<ForId>>.check()
//    }
//}
