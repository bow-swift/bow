import XCTest
@testable import Bow

class ValidatedTest: XCTestCase {
    
    var generator : (Int) -> ValidatedOf<Int, Int> {
        return { a in Validated<Int, Int>.pure(a) }
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
    
    func testShowLaws() {
        ShowLaws.check(show: Validated.show(), generator: { a in (a % 2 == 0) ? Validated.valid(a) : Validated.invalid(a) })
    }
}
