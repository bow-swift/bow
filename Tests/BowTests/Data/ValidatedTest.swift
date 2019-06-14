import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

class ValidatedTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ValidatedPartial<Int>, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ValidatedPartial<Int>>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ValidatedPartial<Int>>.check()
    }
    
    func testSelectiveLaws() {
        SelectiveLaws<ValidatedPartial<Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ValidatedPartial<Int>>.check()
    }

    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Validated<Int, Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ValidatedPartial<Int>>.check()
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<ValidatedPartial<CategoryError>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ValidatedPartial<Int>>.check()
    }
    
    func testCheckers() {
        property("valid and invalid are mutually exclusive") <- forAll { (input: Validated<Int, Int>) in
            return xor(input.isValid, input.isInvalid)
        }
    }
    
    func testConversionConsistency() {
        property("Consistency fromOption - toOption") <- forAll { (option: Option<Int>, none: String) in
            return Validated.fromOption(option, ifNone: constant(none)).toOption() == option
        }
        
        property("Consistency fromEither - toEither") <- forAll { (either: Either<Int, Int>) in
            return Validated.fromEither(either)^.toEither() == either
        }
        
        property("Consistency fromTry - toList") <- forAll { (attempt: Try<Int>) in
            let validated = Validated<TryError, Int>.fromTry(attempt)
            return (validated.isValid && validated.toArray().count == 1) ||
                    (validated.isInvalid && validated.toArray() == [])
        }
    }

    func testSwapIsomorphism() {
        property("swap twice is equivalent to id") <- forAll { (input: Validated<Int, Int>) in
            return input.swap().swap() == input
        }
    }
}
