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
    
    private let nelGenerator = ArrayOf<Int>.arbitrary.suchThat { array in array.getArray.count > 0 }
    
    func testConcatenation() {
        property("The length of the concatenation is equal to the sum of lenghts") <- forAll(self.nelGenerator, self.nelGenerator) { (x : ArrayOf<Int>, y : ArrayOf<Int>) in
            let a = NonEmptyList.fromArrayUnsafe(x.getArray)
            let b = NonEmptyList.fromArrayUnsafe(y.getArray)
            return a.count + b.count == (a + b).count
        }
        
        property("Adding one element increases length in one") <- forAll(self.nelGenerator, Int.arbitrary) { (array : ArrayOf<Int>, element : Int) in
            let nel = NonEmptyList.fromArrayUnsafe(array.getArray)
            return (nel + element).count == nel.count + 1
        }
        
        property("Result of concatenation contains all items from the original lists") <- forAll(self.nelGenerator, self.nelGenerator) {
            (x : ArrayOf<Int>, y : ArrayOf<Int>) in
            let a = NonEmptyList.fromArrayUnsafe(x.getArray)
            let b = NonEmptyList.fromArrayUnsafe(y.getArray)
            let concatenation = a + b
            return concatenation.containsAll(elements: a.all()) &&
                    concatenation.containsAll(elements: b.all())
        }
    }
}
