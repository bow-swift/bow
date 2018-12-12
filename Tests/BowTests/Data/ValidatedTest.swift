import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class ValidatedTest: XCTestCase {
    
    var generator : (Int) -> Validated<Int, Int> {
        return { a in (a % 2 == 0) ? Validated.pure(a) : Validated.invalid(a) }
    }
    
    let eq = Validated.eq(Int.order, Int.order)
    let eqUnit = Validated.eq(Int.order, UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ValidatedPartial<Int>>.check(functor: Validated<Int, Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ValidatedPartial<Int>>.check(applicative: Validated<Int, Int>.applicative(Int.sumMonoid), eq: self.eq)
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ValidatedPartial<Int>>.check(semigroupK: Validated<Int, Int>.semigroupK(Int.sumMonoid), generator: self.generator, eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("Validated semigroupK algebra semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws.check(
                semigroup: Validated<Int, Int>.semigroupK(Int.sumMonoid).algebra(),
                a: Validated.valid(a),
                b: Validated.valid(b),
                c: Validated.valid(c),
                eq: self.eq)
        }
    }
    
    func testShowLaws() {
        ShowLaws.check(show: Validated.show(), generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ValidatedPartial<Int>>.check(foldable: Validated<Int, Int>.foldable(), generator: self.generator)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<ValidatedPartial<CategoryError>, CategoryError>.check(
            applicativeError: Validated<CategoryError, Int>.applicativeError(CategoryError.semigroup),
            eq: Validated.eq(CategoryError.eq, Int.order),
            eqEither: Validated.eq(CategoryError.eq, Either.eq(CategoryError.eq, Int.order)),
            gen: { CategoryError.common })
    }
    
    func testTraverseLaws() {
        TraverseLaws<ValidatedPartial<Int>>.check(traverse: Validated<Int, Int>.traverse(), functor: Validated<Int, Int>.functor(), generator: self.generator, eq: self.eq)
    }
    
    func testCheckers() {
        property("valid and invalid are mutually exclusive") <- forAll { (x : Int) in
            let input = self.generator(x)
            return xor(input.isValid, input.isInvalid)
        }
    }
    
    func testConversionConsistency() {
        property("Consistency fromOption - toOption") <- forAll { (x : Int?, none : String) in
            let option = Option<Int>.fromOptional(x)
            let validated = Validated.fromOption(option, ifNone: constant(none))
            return Option<Int>.eq(Int.order).eqv(validated.toOption(), option)
        }
        
        property("Consistency fromEither - toEither") <- forAll { (x : Int) in
            let either = x % 2 == 0 ? Either.left(x) : Either.right(x)
            let validated = Validated.fromEither(either)
            return Either<Int, Int>.eq(Int.order, Int.order).eqv(validated.toEither(), either)
        }
        
        property("Consistency fromTry - toList") <- forAll { (x : Int) in
            let attempt = x % 2 == 0 ? Try.success(x) : Try.failure(TryError.illegalState)
            let validated = Validated<TryError, Int>.fromTry(attempt)
            return (validated.isValid && validated.toList() == [x]) ||
                    (validated.isInvalid && validated.toList() == [])
        }
    }
    
    func testBimapEquivalence() {
        property("bimap is equivalent to map and leftMap") <- forAll { (x : Int, f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>) in
            let input = self.generator(x)
            return self.eq.eqv(input.bimap(f.getArrow, g.getArrow),
                               input.map(g.getArrow).leftMap(f.getArrow))
        }
    }
    
    func testSwapIsomorphism() {
        property("swap twice is equivalent to id") <- forAll { (x : Int) in
            let input = self.generator(x)
            return self.eq.eqv(input.swap().swap(),
                               input)
        }
    }
}
