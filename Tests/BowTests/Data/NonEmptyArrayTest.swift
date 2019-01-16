import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class NonEmptyArrayTest: XCTestCase {
    
    var generator : (Int) -> NonEmptyArray<Int> {
        return { a in NonEmptyArray.pure(a) }
    }
    
    let eq = NonEmptyArray.eq(Int.order)
    let eqUnit = NonEmptyArray.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForNonEmptyArray>.check(functor: NonEmptyArray<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForNonEmptyArray>.check(applicative: NonEmptyArray<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForNonEmptyArray>.check(monad: NonEmptyArray<Int>.monad(), eq: self.eq)
    }
    
    func testComonadLaws() {
        ComonadLaws<ForNonEmptyArray>.check(comonad: NonEmptyArray<Int>.comonad(), generator: self.generator, eq: self.eq)
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForNonEmptyArray>.check(bimonad: NonEmptyArray<Int>.bimonad(), generator: self.generator, eq: self.eq)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForNonEmptyArray>.check(traverse: NonEmptyArray<Int>.traverse(), functor: NonEmptyArray<Int>.functor(), generator: self.generator, eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("NonEmptyArray semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<NonEmptyArrayOf<Int>>.check(
                    semigroup: NonEmptyArray<Int>.semigroup(),
                    a: NonEmptyArray<Int>.pure(a),
                    b: NonEmptyArray<Int>.pure(b),
                    c: NonEmptyArray<Int>.pure(c),
                    eq: self.eq)
        }
        
        property("NonEmptyArray semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws<NonEmptyArrayOf<Int>>.check(
                semigroup: NonEmptyArray<Int>.semigroupK().algebra(),
                a: NonEmptyArray<Int>.pure(a),
                b: NonEmptyArray<Int>.pure(b),
                c: NonEmptyArray<Int>.pure(c),
                eq: self.eq)
        }
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ForNonEmptyArray>.check(semigroupK: NonEmptyArray<Int>.semigroupK(), generator: self.generator, eq: self.eq)
    }
    
    func testShowLaws() {
        ShowLaws.check(show: NonEmptyArray.show(), generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForNonEmptyArray>.check(foldable: NonEmptyArray<Int>.foldable(), generator: self.generator)
    }
    
    private let neaGenerator = ArrayOf<Int>.arbitrary.suchThat { array in array.getArray.count > 0 }
    
    func testConcatenation() {
        property("The length of the concatenation is equal to the sum of lenghts") <- forAll(self.neaGenerator, self.neaGenerator) { (x : ArrayOf<Int>, y : ArrayOf<Int>) in
            let a = NonEmptyArray.fromArrayUnsafe(x.getArray)
            let b = NonEmptyArray.fromArrayUnsafe(y.getArray)
            return a.count + b.count == (a + b).count
        }
        
        property("Adding one element increases length in one") <- forAll(self.neaGenerator, Int.arbitrary) { (array : ArrayOf<Int>, element : Int) in
            let nea = NonEmptyArray.fromArrayUnsafe(array.getArray)
            return (nea + element).count == nea.count + 1
        }
        
        property("Result of concatenation contains all items from the original arrays") <- forAll(self.neaGenerator, self.neaGenerator) {
            (x : ArrayOf<Int>, y : ArrayOf<Int>) in
            let a = NonEmptyArray.fromArrayUnsafe(x.getArray)
            let b = NonEmptyArray.fromArrayUnsafe(y.getArray)
            let concatenation = a + b
            return concatenation.containsAll(elements: a.all()) &&
                    concatenation.containsAll(elements: b.all())
        }
    }
}
