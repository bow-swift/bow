import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class NonEmptyArrayTest: XCTestCase {
    
    var generator: (Int) -> NonEmptyArray<Int> {
        return { a in NonEmptyArray(head: a, tail: []) }
    }

    func testEquatableLaws() {
        EquatableKLaws.check(generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForNonEmptyArray>.check(generator: self.generator)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForNonEmptyArray>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<ForNonEmptyArray>.check()
    }

    func testMonadLaws() {
        MonadLaws<ForNonEmptyArray>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<ForNonEmptyArray>.check(generator: self.generator)
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForNonEmptyArray>.check(generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForNonEmptyArray>.check(generator: self.generator)
    }
    
    func testSemigroupLaws() {
        property("NonEmptyArray semigroup laws") <- forAll { (a: Int, b: Int, c: Int) in
            return SemigroupLaws<NonEmptyArray<Int>>.check(
                a: NonEmptyArray<Int>(head: a, tail: []),
                    b: NonEmptyArray<Int>(head: b, tail: []),
                    c: NonEmptyArray<Int>(head: c, tail: []))
        }
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ForNonEmptyArray>.check(generator: self.generator)
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws.check(generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForNonEmptyArray>.check(generator: self.generator)
    }
    
    private let neaGenerator = Array<Int>.arbitrary.suchThat { array in array.count > 0 }
    
    func testConcatenation() {
        property("The length of the concatenation is equal to the sum of lenghts") <- forAll(self.neaGenerator, self.neaGenerator) { (x: Array<Int>, y: Array<Int>) in
            let a = NonEmptyArray.fromArrayUnsafe(x)
            let b = NonEmptyArray.fromArrayUnsafe(y)
            return a.count + b.count == (a + b).count
        }
        
        property("Adding one element increases length in one") <- forAll(self.neaGenerator, Int.arbitrary) { (array: Array<Int>, element: Int) in
            let nea = NonEmptyArray.fromArrayUnsafe(array)
            return (nea + element).count == nea.count + 1
        }
        
        property("Result of concatenation contains all items from the original arrays") <- forAll(self.neaGenerator, self.neaGenerator) {
            (x: Array<Int>, y: Array<Int>) in
            let a = NonEmptyArray.fromArrayUnsafe(x)
            let b = NonEmptyArray.fromArrayUnsafe(y)
            let concatenation = a + b
            return concatenation.containsAll(elements: a.all()) &&
                    concatenation.containsAll(elements: b.all())
        }
    }
}
