import XCTest
import SwiftCheck
@testable import Bow

class NonEmptyListTest: XCTestCase {
    
    var generator : (Int) -> NonEmptyList<Int> {
        return { a in NonEmptyList.pure(a) }
    }
    
    let eq = NonEmptyList.eq(Int.order)
    let eqUnit = NonEmptyList.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForNonEmptyList>.check(functor: NonEmptyList<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForNonEmptyList>.check(applicative: NonEmptyList<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForNonEmptyList>.check(monad: NonEmptyList<Int>.monad(), eq: self.eq)
    }
    
    func testComonadLaws() {
        ComonadLaws<ForNonEmptyList>.check(comonad: NonEmptyList<Int>.comonad(), generator: self.generator, eq: self.eq)
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForNonEmptyList>.check(bimonad: NonEmptyList<Int>.bimonad(), generator: self.generator, eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("NonEmptyList semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<NonEmptyListOf<Int>>.check(
                    semigroup: NonEmptyList<Int>.semigroup(),
                    a: NonEmptyList<Int>.pure(a),
                    b: NonEmptyList<Int>.pure(b),
                    c: NonEmptyList<Int>.pure(c),
                    eq: self.eq)
        }
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ForNonEmptyList>.check(semigroupK: NonEmptyList<Int>.semigroupK(), generator: self.generator, eq: self.eq)
    }
    
    func testShowLaws() {
        ShowLaws.check(show: NonEmptyList.show(), generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForNonEmptyList>.check(foldable: NonEmptyList<Int>.foldable(), generator: self.generator)
    }
}
