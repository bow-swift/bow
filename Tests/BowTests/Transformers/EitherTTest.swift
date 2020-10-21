import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

class EitherTTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<EitherTPartial<ForId, Int>, Int>.check()
    }

    func testHashableKLaws() {
        HashableKLaws<EitherTPartial<ForId, Int>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherTPartial<ForId, Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherTPartial<ForId, Int>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<EitherTPartial<ForId, Int>>.check()
    }

    func testMonadLaws() {
        MonadLaws<EitherTPartial<ForId, Int>>.check()
    }

    func testMonadTransLaws() {
        MonadTransLaws<EitherTPartial<ForId, Int>, String, Int>.check()
        MonadTransLaws<EitherTPartial<ForOption, Int>, String, Int>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<EitherTPartial<ForId, Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<EitherTPartial<ForId, Int>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<EitherTPartial<ForId, Int>>.check()
    }

    func testOptionTConversion() {
        property("Left converted to none") <~ forAll { (x: Int) in
            let eitherT = EitherT<ForId, Int, Int>.left(x)
            let expected = OptionT<ForId, Int>.none()
            return eitherT.toOptionT() == expected
        }
        
        property("Right converted to some") <~ forAll { (x: Int) in
            let eitherT = EitherT<ForId, Int, Int>.right(x)
            let expected = OptionT<ForId, Int>.pure(x)
            return eitherT.toOptionT() == expected
        }
    }
}
