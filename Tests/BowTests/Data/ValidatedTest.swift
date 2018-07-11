import XCTest
import SwiftCheck
@testable import Bow

class ValidatedTest: XCTestCase {
    
    var generator : (Int) -> Validated<Int, Int> {
        return { a in (a % 2 == 0) ? Validated.valid(a) : Validated.invalid(a) }
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
}
