import XCTest
import SwiftCheck
import BowLaws
import Bow

class NonEmptyArrayTest: XCTestCase {
    func testEquatableLaws() {
        EquatableKLaws<NonEmptyArrayPartial, Int>.check()
    }

    func testHashableKLaws() {
        HashableKLaws<NonEmptyArrayPartial, Int>.check()
    }
    
    func testFunctorLaws() {
        FunctorLaws<NonEmptyArrayPartial>.check()
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<NonEmptyArrayPartial>.check()
    }

    func testSelectiveLaws() {
        SelectiveLaws<NonEmptyArrayPartial>.check()
    }

    func testMonadLaws() {
        MonadLaws<NonEmptyArrayPartial>.check()
    }
    
    func testComonadLaws() {
        ComonadLaws<NonEmptyArrayPartial>.check()
    }
    
    func testBimonadLaws() {
        BimonadLaws<NonEmptyArrayPartial>.check()
    }
    
    func testTraverseLaws() {
        TraverseLaws<NonEmptyArrayPartial>.check()
    }
    
    func testSemigroupLaws() {
        SemigroupLaws<NonEmptyArray<Int>>.check()
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<NonEmptyArrayPartial>.check()
    }
    
    func testCustomStringConvertibleLaws() {
        CustomStringConvertibleLaws<NEA<Int>>.check()
    }
    
    func testFoldableLaws() {
        FoldableLaws<NonEmptyArrayPartial>.check()
    }
    
    func testConcatenation() {
        property("The length of the concatenation is equal to the sum of lenghts") <~ forAll { (a: NEA<Int>, b: NEA<Int>) in
            a.count + b.count == (a + b).count
        }
        
        property("Adding one element increases length in one") <~ forAll { (nea: NEA<Int>, element: Int) in
            (nea + element).count == nea.count + 1
        }
        
        property("Result of concatenation contains all items from the original arrays") <~ forAll { (a: NEA<Int>, b: NEA<Int>) in
            let concatenation = a + b
            return concatenation.containsAll(elements: a.all()) &&
                    concatenation.containsAll(elements: b.all())
        }
    }
}
