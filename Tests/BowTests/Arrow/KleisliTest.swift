import XCTest
@testable import BowLaws
import Bow
import SwiftCheck

// MARK: Instance of EquatableK for Kleisli
extension KleisliPartial: EquatableK where F: EquatableK, D == Int {
    public static func eq<A: Equatable>(
        _ lhs: KleisliOf<F, D, A>,
        _ rhs: KleisliOf<F, D, A>) -> Bool {
        lhs^.run(1) == rhs^.run(1)
    }
}

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
