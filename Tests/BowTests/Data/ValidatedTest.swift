import XCTest
import SwiftCheck
@testable import BowLaws
import Bow

class ValidatedTest: XCTestCase {
    
    var generator: (Int) -> Validated<Int, Int> {
        return { a in (a % 2 == 0) ? Validated.valid(a) : Validated.invalid(a) }
    }

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
        SemigroupKLaws<ValidatedPartial<Int>>.check(generator: self.generator)
    }

    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<Validated<Int, Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ValidatedPartial<Int>>.check(generator: self.generator)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<ValidatedPartial<CategoryError>>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ValidatedPartial<Int>>.check(generator: self.generator)
    }
    
    func testCheckers() {
        property("valid and invalid are mutually exclusive") <- forAll { (x: Int) in
            let input = self.generator(x)
            return xor(input.isValid, input.isInvalid)
        }
    }
    
    func testConversionConsistency() {
        property("Consistency fromOption - toOption") <- forAll { (x: Int?, none: String) in
            let option = Option<Int>.fromOptional(x)
            let validated = Validated.fromOption(option, ifNone: constant(none))
            return validated.toOption() == option
        }
        
        property("Consistency fromEither - toEither") <- forAll { (x: Int) in
            let either = x % 2 == 0 ? Either.left(x) : Either.right(x)
            let validated = Validated.fix(Validated.fromEither(either))
            return validated.toEither() == either
        }
        
        property("Consistency fromTry - toList") <- forAll { (x: Int) in
            let attempt = x % 2 == 0 ? Try.success(x) : Try.failure(TryError.illegalState)
            let validated = Validated<TryError, Int>.fromTry(attempt)
            return (validated.isValid && validated.toArray() == [x]) ||
                    (validated.isInvalid && validated.toArray() == [])
        }
    }

    func testSwapIsomorphism() {
        property("swap twice is equivalent to id") <- forAll { (x : Int) in
            let input = self.generator(x)
            return input.swap().swap() == input
        }
    }
}
