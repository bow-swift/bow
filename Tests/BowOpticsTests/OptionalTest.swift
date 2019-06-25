import XCTest
import SwiftCheck
import Bow
import BowOptics

class OptionalTest: XCTestCase {

    func testOptionalLaws() {
        OptionalLaws.check(optional: BowOptics.Optional<String, String>.identity())
    }

    func testSetterLaws() {
        SetterLaws.check(setter: BowOptics.Optional<String, String>.identity().asSetter())
    }

    func testTraversalLaws() {
        TraversalLaws.check(traversal: BowOptics.Optional<String, String>.identity().asTraversal())
    }

    func testOptionalAsFold() {
        property("Optional as Fold: size") <- forAll { (ints: Array<Int>) in
            return optionalHead.asFold().size(ints) == Option.fix(Option.fromOptional(ints.first).map(constant(1))).getOrElse(0)
        }

        property("Optional as Fold: nonEmpty") <- forAll { (ints: Array<Int>) in
            return optionalHead.asFold().nonEmpty(ints) == Option.fromOptional(ints.first).isDefined
        }

        property("Optional as Fold: isEmpty") <- forAll { (ints: Array<Int>) in
            return optionalHead.asFold().isEmpty(ints) == Option.fromOptional(ints.first).isEmpty
        }

        property("Optional as Fold: getAll") <- forAll { (ints: Array<Int>) in
            return optionalHead.asFold().getAll(ints) ==
                Option.fromOptional(ints.first).toArray().k()
        }

        property("Optional as Fold: combineAll") <- forAll { (ints: Array<Int>) in
            return optionalHead.asFold().combineAll(ints) == Option.fromOptional(ints.first).fold(constant(Int.empty()), id)
        }

        property("Optional as Fold: fold") <- forAll { (ints: Array<Int>) in
            return optionalHead.asFold().fold(ints) == Option.fromOptional(ints.first).fold(constant(Int.empty()), id)
        }

        property("Optional as Fold: headOption") <- forAll { (ints: Array<Int>) in
            return optionalHead.asFold().headOption(ints) ==
                Option.fromOptional(ints.first)
        }

        property("Optional as Fold: lastOption") <- forAll { (ints: Array<Int>) in
            return optionalHead.asFold().lastOption(ints) ==
                Option.fromOptional(ints.first)
        }
    }

    func testOptionalProperties() {
        property("void should always return none") <- forAll { (value: String) in
            let void = BowOptics.Optional<String, Int>.void()
            return void.getOption(value) == Option<Int>.none()
        }

        property("void should return source when setting target") <- forAll { (str: String, int: Int) in
            let void = BowOptics.Optional<String, Int>.void()
            return void.set(str, int) == str
        }

        property("Checking if there is no target") <- forAll { (ints: Array<Int>) in
            return optionalHead.nonEmpty(ints) == !ints.isEmpty
        }

        property("Checking if a target exists") <- forAll { (ints: Array<Int>) in
            return optionalHead.isEmpty(ints) == ints.isEmpty
        }

        property("lift should be consistent with modify") <- forAll { (ints: Array<Int>, f: ArrowOf<Int, Int>) in
            return optionalHead.lift(f.getArrow)(ints) == optionalHead.modify(ints, f.getArrow)
        }

        property("liftF should be consistent with modifyF") <- forAll { (ints: Array<Int>, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> Try.pure
            return optionalHead.liftF(g)(ints) ==
                optionalHead.modifyF(ints, g)
        }

        property("Finding a target using a predicate should be wrapped in the correct option result") <- forAll { (ints: Array<Int>, predicate: Bool) in
            return optionalHead.find(ints, constant(predicate)).fold(constant(false), constant(true)) == predicate || ints.isEmpty
        }

        property("Checking existence predicate over the target should result in same result as predicate") <- forAll { (ints: Array<Int>, predicate: Bool) in
            return optionalHead.exists(ints, constant(predicate)) == predicate || ints.isEmpty
        }

        property("Checking satisfaction of predicate over the target should result in opposite result as predicate") <- forAll { (ints: Array<Int>, predicate: Bool) in
            return optionalHead.all(ints, constant(predicate)) == predicate || ints.isEmpty
        }

        property("Joining two optionals together with same target should yield same result") <- forAll { (int: Int) in
            let joinedOptional = optionalHead.choice(defaultHead)
            return joinedOptional.getOption(Either.left([int])) == joinedOptional.getOption(Either.right(int))
        }
    }

    func testOptionalComposition() {
        property("Optional + Optional::identity") <- forAll { (array: Array<Int>, def: Int) in
            return (optionalHead + BowOptics.Optional<Int, Int>.identity()).getOption(array).getOrElse(def) == optionalHead.getOption(array).getOrElse(def)
        }

        property("Optional + Iso::identity") <- forAll { (array: Array<Int>, def: Int) in
            return (optionalHead + Iso<Int, Int>.identity).getOption(array).getOrElse(def) == optionalHead.getOption(array).getOrElse(def)
        }

        property("Optional + Lens::identity") <- forAll { (array: Array<Int>, def: Int) in
            return (optionalHead + Lens<Int, Int>.identity()).getOption(array).getOrElse(def) == optionalHead.getOption(array).getOrElse(def)
        }

        property("Optional + Prism::identity") <- forAll { (array: Array<Int>, def: Int) in
            return (optionalHead + Prism<Int, Int>.identity()).getOption(array).getOrElse(def) == optionalHead.getOption(array).getOrElse(def)
        }

        property("Optional + Getter::identity") <- forAll { (array: Array<Int>) in
            return (optionalHead + Getter<Int, Int>.identity()).getAll(array).asArray == optionalHead.getOption(array).fold(constant([]), { x in [x] })
        }

        let nonEmptyGenerator = Array<Int>.arbitrary.suchThat { array in array.count > 0 }
        property("Optional + Setter::identity") <- forAll(nonEmptyGenerator, Int.arbitrary) { (array: Array<Int>, def: Int) in
            return (optionalHead + Setter<Int, Int>.identity()).set(array, def) == optionalHead.set(array, def)
        }

        property("Optional + Fold::identity") <- forAll { (array: Array<Int>) in
            return (optionalHead + Fold<Int, Int>.identity()).getAll(array).asArray == optionalHead.getOption(array).fold(constant([]), { x in [x] })
        }

        property("Optional + Traversal::identity") <- forAll { (array: Array<Int>) in
            return (optionalHead + Traversal<Int, Int>.identity()).getAll(array).asArray == optionalHead.getOption(array).fold(constant([]), { x in [x] })
        }
    }
}
