import XCTest
import SwiftCheck
import Bow
import BowOptics
import BowOpticsLaws
import BowLaws

class AffineTraversalTest: XCTestCase {

    func testAffineTraversalLaws() {
        AffineTraversalLaws.check(affineTraversal: AffineTraversal<String, String>.identity)
    }

    func testSetterLaws() {
        SetterLaws.check(setter: AffineTraversal<String, String>.identity.asSetter)
    }

    func testTraversalLaws() {
        TraversalLaws.check(traversal: AffineTraversal<String, String>.identity.asTraversal)
    }

    func testAffineTraversalAsFold() {
        property("AffineTraversal as Fold: size") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.asFold.size(ints) == Option.fix(Option.fromOptional(ints.first).map(constant(1))).getOrElse(0)
        }

        property("AffineTraversal as Fold: nonEmpty") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.asFold.nonEmpty(ints) == Option.fromOptional(ints.first).isDefined
        }

        property("AffineTraversal as Fold: isEmpty") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.asFold.isEmpty(ints) == Option.fromOptional(ints.first).isEmpty
        }

        property("AffineTraversal as Fold: getAll") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.asFold.getAll(ints) ==
                Option.fromOptional(ints.first).toArray().k()
        }

        property("AffineTraversal as Fold: combineAll") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.asFold.combineAll(ints) == Option.fromOptional(ints.first).fold(constant(Int.empty()), id)
        }

        property("AffineTraversal as Fold: fold") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.asFold.fold(ints) == Option.fromOptional(ints.first).fold(constant(Int.empty()), id)
        }

        property("AffineTraversal as Fold: headOption") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.asFold.headOption(ints) ==
                Option.fromOptional(ints.first)
        }

        property("AffineTraversal as Fold: lastOption") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.asFold.lastOption(ints) ==
                Option.fromOptional(ints.first)
        }
    }

    func testAffineTraversalProperties() {
        property("void should always return none") <~ forAll { (value: String) in
            let void = AffineTraversal<String, Int>.void
            return void.getOption(value) == Option<Int>.none()
        }

        property("void should return source when setting target") <~ forAll { (str: String, int: Int) in
            let void = AffineTraversal<String, Int>.void
            return void.set(str, int) == str
        }

        property("Checking if there is no target") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.nonEmpty(ints) == !ints.isEmpty
        }

        property("Checking if a target exists") <~ forAll { (ints: Array<Int>) in
            return SumType.optionalHead.isEmpty(ints) == ints.isEmpty
        }

        property("lift should be consistent with modify") <~ forAll { (ints: Array<Int>, f: ArrowOf<Int, Int>) in
            return SumType.optionalHead.lift(f.getArrow)(ints) == SumType.optionalHead.modify(ints, f.getArrow)
        }

        property("liftF should be consistent with modifyF") <~ forAll { (ints: Array<Int>, f: ArrowOf<Int, Int>) in
            let g = f.getArrow >>> Try.pure
            return SumType.optionalHead.liftF(g)(ints) ==
                SumType.optionalHead.modifyF(ints, g)
        }

        property("Finding a target using a predicate should be wrapped in the correct option result") <~ forAll { (ints: Array<Int>, predicate: Bool) in
            return SumType.optionalHead.find(ints, constant(predicate)).fold(constant(false), constant(true)) == predicate || ints.isEmpty
        }

        property("Checking existence predicate over the target should result in same result as predicate") <~ forAll { (ints: Array<Int>, predicate: Bool) in
            return SumType.optionalHead.exists(ints, constant(predicate)) == predicate || ints.isEmpty
        }

        property("Checking satisfaction of predicate over the target should result in opposite result as predicate") <~ forAll { (ints: Array<Int>, predicate: Bool) in
            return SumType.optionalHead.all(ints, constant(predicate)) == predicate || ints.isEmpty
        }

        property("Joining two optionals together with same target should yield same result") <~ forAll { (int: Int) in
            let joinedOptional = SumType.optionalHead.choice(SumType.defaultHead)
            return joinedOptional.getOption(Either.left([int])) == joinedOptional.getOption(Either.right(int))
        }
    }

    func testAffineTraversalComposition() {
        property("AffineTraversal + AffineTraversal::identity") <~ forAll { (array: Array<Int>, def: Int) in
            return (SumType.optionalHead + AffineTraversal<Int, Int>.identity).getOption(array).getOrElse(def) == SumType.optionalHead.getOption(array).getOrElse(def)
        }

        property("AffineTraversal + Iso::identity") <~ forAll { (array: Array<Int>, def: Int) in
            return (SumType.optionalHead + Iso<Int, Int>.identity).getOption(array).getOrElse(def) == SumType.optionalHead.getOption(array).getOrElse(def)
        }

        property("AffineTraversal + Lens::identity") <~ forAll { (array: Array<Int>, def: Int) in
            return (SumType.optionalHead + Lens<Int, Int>.identity).getOption(array).getOrElse(def) == SumType.optionalHead.getOption(array).getOrElse(def)
        }

        property("AffineTraversal + Prism::identity") <~ forAll { (array: Array<Int>, def: Int) in
            return (SumType.optionalHead + Prism<Int, Int>.identity).getOption(array).getOrElse(def) == SumType.optionalHead.getOption(array).getOrElse(def)
        }

        property("AffineTraversal + Getter::identity") <~ forAll { (array: Array<Int>) in
            return (SumType.optionalHead + Getter<Int, Int>.identity).getAll(array).asArray == SumType.optionalHead.getOption(array).fold(constant([]), { x in [x] })
        }

        let nonEmptyGenerator = Array<Int>.arbitrary.suchThat { array in array.count > 0 }
        property("AffineTraversal + Setter::identity") <~ forAll(nonEmptyGenerator, Int.arbitrary) { (array: Array<Int>, def: Int) in
            return (SumType.optionalHead + Setter<Int, Int>.identity).set(array, def) == SumType.optionalHead.set(array, def)
        }

        property("AffineTraversal + Fold::identity") <~ forAll { (array: Array<Int>) in
            return (SumType.optionalHead + Fold<Int, Int>.identity).getAll(array).asArray == SumType.optionalHead.getOption(array).fold(constant([]), { x in [x] })
        }

        property("AffineTraversal + Traversal::identity") <~ forAll { (array: Array<Int>) in
            return (SumType.optionalHead + Traversal<Int, Int>.identity).getAll(array).asArray == SumType.optionalHead.getOption(array).fold(constant([]), { x in [x] })
        }
    }
}
