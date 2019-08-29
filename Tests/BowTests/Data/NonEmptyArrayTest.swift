import XCTest
import SwiftCheck
import BowLaws
import Bow

class NonEmptyArrayTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<ForNonEmptyArray, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForNonEmptyArray>.check()
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
        ComonadLaws<ForNonEmptyArray>.check()
    }
    
    func testBimonadLaws() {
        BimonadLaws<ForNonEmptyArray>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForNonEmptyArray>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<NonEmptyArray<Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<ForNonEmptyArray>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<NEA<Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForNonEmptyArray>.check()
    }
    
    func testConcatenation() {
        property("The length of the concatenation is equal to the sum of lenghts") <~ forAll { (a: NEA<Int>, b: NEA<Int>) in
            return a.count + b.count == (a + b).count
        }
        
        property("Adding one element increases length in one") <~ forAll { (nea: NEA<Int>, element: Int) in
            return (nea + element).count == nea.count + 1
        }
        
        property("Result of concatenation contains all items from the original arrays") <~ forAll { (a: NEA<Int>, b: NEA<Int>) in
            let concatenation = a + b
            return concatenation.containsAll(elements: a.all()) &&
                    concatenation.containsAll(elements: b.all())
        }
    }
}
