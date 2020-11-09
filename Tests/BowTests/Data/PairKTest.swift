import XCTest
import BowLaws
import Bow
import BowGenerators
import SwiftCheck

class PairKTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<PairKPartial<ForId, ForId>, Int>.check()
    }

    func testHashableLaws() {
        HashableKLaws<PairKPartial<ForId, ForId>, Int>.check()
    }

    func testInvariantLaws() {
        InvariantLaws<PairKPartial<ForId, ForId>>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<PairKPartial<ForId, ForId>>.check()
    }

    func testApplicativeLaws() {
        ApplicativeLaws<PairKPartial<ForId, ForId>>.check()
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<PairKPartial<ForOption, ForOption>>.check()
    }
    
    func testMonadFilterLaws() {
        MonadFilterLaws<PairKPartial<ForOption, ForOption>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<PairKPartial<ForOption, ForOption>>.check()
    }

    func testMonoidKLaws() {
        SemigroupKLaws<PairKPartial<ForOption, ForOption>>.check()
    }

    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<PairKPartial<EitherPartial<Int>, EitherPartial<Int>>>.check()
    }

    func testMonadErrorLaws() {
        MonadErrorLaws<PairKPartial<EitherPartial<Int>, EitherPartial<Int>>>.check()
    }
}
