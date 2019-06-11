import XCTest
@testable import BowLaws
@testable import Bow

class KleisliTest: XCTestCase {
    var generator: (Int) -> KleisliOf<ForId, Int, Int> {
        return { a in Kleisli.pure(a) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<KleisliPartial<ForId, Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<KleisliPartial<ForId, Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<KleisliPartial<ForId, Int>>.check()
    }

    func testMonadLaws() {
        MonadLaws<KleisliPartial<ForId, Int>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<KleisliPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<KleisliPartial<EitherPartial<CategoryError>, Int>>.check()
    }
}
