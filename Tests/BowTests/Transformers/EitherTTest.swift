import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class EitherTTest: XCTestCase {
    var generator: (Int) -> EitherT<ForId, Int, Int> {
        return { a in a % 2 == 0 ? EitherT.right(a)
                                 : EitherT.left(a)
        }
    }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherTPartial<ForId, Int>>.check(generator: self.generator)
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
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherTPartial<EitherPartial<CategoryError>, Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<EitherTPartial<ForId, Int>>.check(generator: self.generator)
    }

    func testOptionTConversion() {
        property("Left converted to none") <- forAll { (x: Int) in
            let eitherT = EitherT<ForId, Int, Int>.left(x)
            let expected = OptionT<ForId, Int>.none()
            return eitherT.toOptionT() == expected
        }
        
        property("Right converted to some") <- forAll { (x: Int) in
            let eitherT = EitherT<ForId, Int, Int>.right(x)
            let expected = OptionT<ForId, Int>.pure(x)
            return eitherT.toOptionT() == expected
        }
    }
}
