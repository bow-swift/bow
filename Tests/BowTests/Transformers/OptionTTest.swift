import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

class OptionTTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<OptionTPartial<ForId>, Int>.check()
    }

    func testHashableKLaws() {
        HashableKLaws<OptionTPartial<ForId>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<OptionTPartial<ForId>>.check()
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

    func testMonadTransLaws() {
        MonadTransLaws<OptionTPartial<ForId>, String, Int>.check()
        MonadTransLaws<OptionTPartial<ForOption>, String, Int>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<OptionTPartial<ForId>>.check()
    }

    func testMonoidKLaws() {
        MonoidKLaws<OptionTPartial<ForId>>.check()
    }
    
    func testFunctorFilterLaws() {
        FunctorFilterLaws<OptionTPartial<ForId>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<OptionTPartial<EitherPartial<CategoryError>>>.check()
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<OptionTPartial<EitherPartial<CategoryError>>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<OptionTPartial<ForId>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<OptionTPartial<ForId>>.check()
    }

    func testTraverseFilterLaws() {
        TraverseFilterLaws<OptionTPartial<ConstPartial<Int>>>.check()
    }
    
    func testMonadWriterLaws() {
        MonadWriterLaws<OptionTPartial<WriterPartial<Int>>>.check()
    }
    
    func testMonadStateLaws() {
        MonadStateLaws<OptionTPartial<StatePartial<Int>>>.check()
    }
    
    func testToLeftWithFunctionWithSome() {
        property("toLeft for .some should build a correct EitherT") <~ forAll { (a: Int, b: String) in
            let optionT = OptionT<ForId, Int>.fromOption(.some(a))
            return optionT.toLeft({ b }) == EitherT<ForId, Int, String>.left(a)
        }
    }

    func testToLeftWithConstantWithSome() {
        property("toLeft for .some should build a correct EitherT") <~ forAll { (a: Int, b: String) in
            let optionT = OptionT<ForId, Int>.fromOption(.some(a))
            return optionT.toLeft(b) == EitherT<ForId, Int, String>.left(a)
        }
    }

    func testToLeftWithFunctionWithNone() {
        property("toLeft for .none should build a correct EitherT") <~ forAll { (b: String) in
            let optionT = OptionT<ForId, Int>.fromOption(.none())
            return optionT.toLeft({ b }) == EitherT<ForId, Int, String>.right(b)
        }
    }

    func testToLeftWithConstantWithNone() {
        property("toLeft for .none should build a correct EitherT") <~ forAll { (b: String) in
            let optionT = OptionT<ForId, Int>.fromOption(.none())
            return optionT.toLeft(b) == EitherT<ForId, Int, String>.right(b)
        }
    }

    func testToRightWithFunctionWithSome() {
        property("toRight for .some should build a correct EitherT") <~ forAll { (a: Int, b: String) in
            let optionT = OptionT<ForId, String>.fromOption(.some(b))
            return optionT.toRight({ a }) == EitherT<ForId, Int, String>.right(b)
        }
    }

    func testToRightWithConstantWithSome() {
        property("toRight for .some should build a correct EitherT") <~ forAll { (a: Int, b: String) in
            let optionT = OptionT<ForId, String>.fromOption(.some(b))
            return optionT.toRight(a) == EitherT<ForId, Int, String>.right(b)
        }
    }

    func testToRightWithFunctionWithNone() {
        property("toRight for .none should build a correct EitherT") <~ forAll { (a: Int) in
            let optionT = OptionT<ForId, String>.fromOption(.none())
            return optionT.toRight({ a }) == EitherT<ForId, Int, String>.left(a)
        }
    }

    func testToRightWithConstantWithNone() {
        property("toRight for .none should build a correct EitherT") <~ forAll { (a: Int) in
            let optionT = OptionT<ForId, String>.fromOption(.none())
            return optionT.toRight(a) == EitherT<ForId, Int, String>.left(a)
        }
    }
}
