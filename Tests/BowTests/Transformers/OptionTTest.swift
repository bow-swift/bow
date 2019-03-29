import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class OptionTTest: XCTestCase {
    
    var generator: (Int) -> OptionTOf<ForId, Int> {
        return { a in OptionT<ForId, Int>.pure(a) }
    }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<OptionTPartial<ForId>>.check(generator: self.generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<OptionTPartial<ForId>>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<OptionTPartial<ForId>>.check()
    }
    
    func testMonadLaws() {
        MonadLaws<OptionTPartial<ForId>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<OptionTPartial<ForId>>.check(generator: self.generator)
    }

    func testMonoidKLaws() {
        MonoidKLaws<OptionTPartial<ForId>>.check(generator: self.generator)
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<OptionTPartial<ForId>>.check(generator: self.generator)
    }

    func testToLeftWithSome() {
        property("toLeft for .some should build a correct EitherT") <- forAll { (a: Int, b: String) in
            let optionT = OptionT<ForId, Int>.fromOption(.some(a))
            return optionT.toLeft({ b }) == EitherT<ForId, Int, String>.left(a)
        }
    }

    func testToLeftWithNone() {
        property("toLeft for .none should build a correct EitherT") <- forAll { (b: String) in
            let optionT = OptionT<ForId, Int>.fromOption(.none())
            return optionT.toLeft({ b }) == EitherT<ForId, Int, String>.right(b)
        }
    }

    func testToRightWithSome() {
        property("toRight for .some should build a correct EitherT") <- forAll { (a: Int, b: String) in
            let optionT = OptionT<ForId, String>.fromOption(.some(b))
            return optionT.toRight({ a }) == EitherT<ForId, Int, String>.right(b)
        }
    }

    func testToRightWithNome() {
        property("toRight for .none should build a correct EitherT") <- forAll { (a: Int) in
            let optionT = OptionT<ForId, String>.fromOption(.none())
            return optionT.toRight({ a }) == EitherT<ForId, Int, String>.left(a)
        }
    }
}
