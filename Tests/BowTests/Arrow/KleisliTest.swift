import XCTest
@testable import BowLaws
import Bow
import SwiftCheck

class KleisliTest: XCTestCase {
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
    
    func testMonadWriterLaws() {
        MonadWriterLaws<KleisliPartial<WriterPartial<Int>, Int>>.check()
    }
}
