import XCTest
import SwiftCheck
@testable import Bow
@testable import BowOptics

class TraversalTest: XCTestCase {
    let arrayKGen: Gen<ArrayKOf<Int>> = Array<Int>.arbitrary.map{ array in array.k() }

    func arrayKTraversal<F: Traverse>() -> Traversal<Kind<F, Int>, Int>{
        return Traversal<Int, Int>.fromTraverse()
    }

    func testTraversalLaws() {
        TraversalLaws.check(traversal: arrayKTraversal(),
                            generatorA: arrayKGen)
    }

    func testSetterLaws() {
        SetterLaws.check(setter: arrayKTraversal().asSetter(),
                         generatorA: arrayKGen)
    }

    func testTraversalAsFold() {
        property("Traversal as Fold: size") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().asFold().size(array.k()) == array.count
        }

        property("Traversal as Fold: nonEmpty") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().asFold().nonEmpty(array.k()) == !array.isEmpty
        }

        property("Traversal as Fold: isEmpty") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().asFold().isEmpty(array.k()) == array.isEmpty
        }

        property("Traversal as Fold: getAll") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().asFold().getAll(array.k()) ==
                array.k()
        }

        property("Traversal as Fold: combineAll") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().asFold().combineAll(array.k()) == array.reduce(0, +)
        }

        property("Traversal as Fold: fold") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().asFold().combineAll(array.k()) == array.reduce(0, +)
        }

        property("Traversal as Fold: headOption") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().asFold().headOption(array.k()) ==
                Option.fromOptional(array.first)
        }

        property("Traversal as Fold: lastOption") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().asFold().lastOption(array.k()) ==
                Option.fromOptional(array.last)
        }
    }

    func testTraversalProperties() {
        property("Getting all targets of a traversal") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().getAll(array.k()) == array.k()
        }

        property("Folding all the values from a traversal") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().fold(array.k()) ==
                array.reduce(0, +)
        }

        property("Combining all the values from a traversal") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().fold(array.k()) ==
                array.reduce(0, +)
        }

        property("Find a target in a traversal") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().find(array.k(), { x in x > 10 }) ==
                Option.fromOptional(array.filter { x in x > 10 }.first)
        }

        property("Size of a traversal") <- forAll { (array: Array<Int>) in
            return self.arrayKTraversal().size(array.k()) == array.count
        }
    }

    func testTraversalComposition() {
        property("Traversal + Traversal::identity") <- forAll { (array: Array<Int>) in
            return (self.arrayKTraversal() + Traversal<Int, Int>.identity()).getAll(array.k()).asArray == self.arrayKTraversal().getAll(array.k()).asArray
        }

        property("Traversal + Iso::identity") <- forAll { (array: Array<Int>) in
            return (self.arrayKTraversal() + Iso<Int, Int>.identity()).getAll(array.k()).asArray == self.arrayKTraversal().getAll(array.k()).asArray
        }

        property("Traversal + Lens::identity") <- forAll { (array: Array<Int>) in
            return (self.arrayKTraversal() + Lens<Int, Int>.identity()).getAll(array.k()).asArray == self.arrayKTraversal().getAll(array.k()).asArray
        }

        property("Traversal + Prism::identity") <- forAll { (array: Array<Int>) in
            return (self.arrayKTraversal() + Prism<Int, Int>.identity()).getAll(array.k()).asArray == self.arrayKTraversal().getAll(array.k()).asArray
        }

        property("Traversal + Optional::identity") <- forAll { (array: Array<Int>) in
            return (self.arrayKTraversal() + BowOptics.Optional<Int, Int>.identity()).getAll(array.k()).asArray == self.arrayKTraversal().getAll(array.k()).asArray
        }

        property("Traversal + Setter::identity") <- forAll { (array: Array<Int>, value: Int) in
            return (self.arrayKTraversal() + Setter<Int, Int>.identity()).set(array.k(), value) == self.arrayKTraversal().set(array.k(), value)
        }

        property("Traversal + Fold::identity") <- forAll { (array: Array<Int>) in
            return (self.arrayKTraversal() + Fold<Int, Int>.identity()).getAll(array.k()).asArray == self.arrayKTraversal().getAll(array.k()).asArray
        }
    }
}
