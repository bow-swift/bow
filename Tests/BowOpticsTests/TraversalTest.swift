import XCTest
import SwiftCheck
import Bow
import BowGenerators
import BowOptics
import BowOpticsLaws
import BowLaws

class TraversalTest: XCTestCase {
    func testTraversalLaws() {
        TraversalLaws<ArrayK<Int>, Int>.check(traversal: ArrayK<Int>.traversal)
    }

    func testSetterLaws() {
        SetterLaws.check(setter: ArrayK<Int>.traversal.asSetter)
    }

    func testTraversalAsFold() {
        property("Traversal as Fold: size") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.asFold.size(array) == array.count
        }

        property("Traversal as Fold: nonEmpty") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.asFold.nonEmpty(array) == !array.isEmpty
        }

        property("Traversal as Fold: isEmpty") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.asFold.isEmpty(array) == array.isEmpty
        }

        property("Traversal as Fold: getAll") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.asFold.getAll(array) == array
        }

        property("Traversal as Fold: combineAll") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.asFold.combineAll(array) == array.asArray.reduce(0, +)
        }

        property("Traversal as Fold: fold") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.asFold.combineAll(array) == array.asArray.reduce(0, +)
        }

        property("Traversal as Fold: headOption") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.asFold.headOption(array) ==
                array.firstOrNone()
        }

        property("Traversal as Fold: lastOption") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.asFold.lastOption(array) ==
                array.asArray.last.toOption()
        }
    }

    func testTraversalProperties() {
        property("Getting all targets of a traversal") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.getAll(array) == array
        }

        property("Folding all the values from a traversal") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.fold(array) ==
                array.asArray.reduce(0, +)
        }

        property("Combining all the values from a traversal") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.fold(array) ==
                array.asArray.reduce(0, +)
        }

        property("Find a target in a traversal") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.find(array, { x in x > 10 }) ==
                array.asArray.filter { x in x > 10 }.first.toOption()
        }

        property("Size of a traversal") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.traversal.size(array) == array.count
        }
    }

    func testTraversalComposition() {
        property("Traversal + Traversal::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.traversal + Traversal<Int, Int>.identity).getAll(array) ==
                ArrayK<Int>.traversal.getAll(array)
        }

        property("Traversal + Iso::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.traversal + Iso<Int, Int>.identity).getAll(array) ==
                ArrayK<Int>.traversal.getAll(array)
        }

        property("Traversal + Lens::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.traversal + Lens<Int, Int>.identity).getAll(array) ==
                ArrayK<Int>.traversal.getAll(array)
        }

        property("Traversal + Prism::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.traversal + Prism<Int, Int>.identity).getAll(array) ==
                ArrayK<Int>.traversal.getAll(array)
        }

        property("Traversal + AffineTraversal::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.traversal + AffineTraversal<Int, Int>.identity).getAll(array) ==
                ArrayK<Int>.traversal.getAll(array)
        }

        property("Traversal + Setter::identity") <~ forAll { (array: ArrayK<Int>, value: Int) in
            return (ArrayK<Int>.traversal + Setter<Int, Int>.identity).set(array, value) ==
                ArrayK<Int>.traversal.set(array, value)
        }

        property("Traversal + Fold::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.traversal + Fold<Int, Int>.identity).getAll(array) ==
                ArrayK<Int>.traversal.getAll(array)
        }
    }
}
