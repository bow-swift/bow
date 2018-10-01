import XCTest
import SwiftCheck
@testable import Bow

class OptionalTest: XCTestCase {
    
    func testOptionalLaws() {
        OptionalLaws.check(optional: Bow.Optional<String, String>.identity(), eqA: String.order, eqB: String.order)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: Bow.Optional<String, String>.identity().asSetter(), eqA: String.order, generatorA: String.arbitrary)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: Bow.Optional<String, String>.identity().asTraversal(), eqA: String.order, eqB: String.order, generatorA: String.arbitrary)
    }
    
    func testOptionalAsFold() {
        property("Optional as Fold: size") <- forAll { (ints : ArrayOf<Int>) in
            return optionalHead.asFold().size(ints.getArray) == Option.fromOption(ints.getArray.first).map(constant(1)).getOrElse(0)
        }
        
        property("Optional as Fold: nonEmpty") <- forAll { (ints : ArrayOf<Int>) in
            return optionalHead.asFold().nonEmpty(ints.getArray) == Option.fromOption(ints.getArray.first).isDefined
        }
        
        property("Optional as Fold: isEmpty") <- forAll { (ints : ArrayOf<Int>) in
            return optionalHead.asFold().isEmpty(ints.getArray) == Option.fromOption(ints.getArray.first).isEmpty
        }
        
        property("Optional as Fold: getAll") <- forAll { (ints : ArrayOf<Int>) in
            return ListK.eq(Int.order).eqv(optionalHead.asFold().getAll(ints.getArray), Option.fromOption(ints.getArray.first).toList().k())
        }
        
        property("Optional as Fold: combineAll") <- forAll { (ints : ArrayOf<Int>) in
            return optionalHead.asFold().combineAll(Int.sumMonoid, ints.getArray) == Option.fromOption(ints.getArray.first).fold(constant(Int.sumMonoid.empty), id)
        }
        
        property("Optional as Fold: fold") <- forAll { (ints : ArrayOf<Int>) in
            return optionalHead.asFold().fold(Int.sumMonoid, ints.getArray) == Option.fromOption(ints.getArray.first).fold(constant(Int.sumMonoid.empty), id)
        }
        
        property("Optional as Fold: headMaybe") <- forAll { (ints : ArrayOf<Int>) in
            return Option.eq(Int.order).eqv(optionalHead.asFold().headMaybe(ints.getArray),
                                           Option.fromOption(ints.getArray.first))
        }
        
        property("Optional as Fold: lastMaybe") <- forAll { (ints : ArrayOf<Int>) in
            return Option.eq(Int.order).eqv(optionalHead.asFold().lastMaybe(ints.getArray),
                                           Option.fromOption(ints.getArray.first))
        }
    }
    
    func testOptionalProperties() {
        property("void should always return none") <- forAll { (value : String) in
            let void = Bow.Optional<String, Int>.void()
            return Option.eq(Int.order).eqv(void.getMaybe(value), Option<Int>.none())
        }
        
        property("void should return source when setting target") <- forAll { (str : String, int : Int) in
            let void = Bow.Optional<String, Int>.void()
            return void.set(str, int) == str
        }
        
        property("Checking if there is no target") <- forAll { (ints : ArrayOf<Int>) in
            return optionalHead.nonEmpty(ints.getArray) == !ints.getArray.isEmpty
        }
        
        property("Checking if a target exists") <- forAll { (ints : ArrayOf<Int>) in
            return optionalHead.isEmpty(ints.getArray) == ints.getArray.isEmpty
        }
        
        property("lift should be consistent with modify") <- forAll { (ints : ArrayOf<Int>, f : ArrowOf<Int, Int>) in
            return optionalHead.lift(f.getArrow)(ints.getArray) == optionalHead.modify(ints.getArray, f.getArrow)
        }
        
        property("liftF should be consistent with modifyF") <- forAll { (ints : ArrayOf<Int>, f : ArrowOf<Int, Int>) in
            let g = f.getArrow >>> Try.pure
            return Try.eq(Array<Int>.eq(Int.order)).eqv(
                optionalHead.liftF(Try<Int>.applicative(), g)(ints.getArray),
                optionalHead.modifyF(Try<Int>.applicative(), ints.getArray, g))
        }
        
        property("Finding a target using a predicate should be wrapped in the correct option result") <- forAll { (ints : ArrayOf<Int>, predicate : Bool) in
            return optionalHead.find(ints.getArray, constant(predicate)).fold(constant(false), constant(true)) == predicate || ints.getArray.isEmpty
        }
        
        property("Checking existence predicate over the target should result in same result as predicate") <- forAll { (ints : ArrayOf<Int>, predicate : Bool) in
            return optionalHead.exists(ints.getArray, constant(predicate)) == predicate || ints.getArray.isEmpty
        }
        
        property("Checking satisfaction of predicate over the target should result in opposite result as predicate") <- forAll { (ints : ArrayOf<Int>, predicate : Bool) in
            return optionalHead.all(ints.getArray, constant(predicate)) == predicate || ints.getArray.isEmpty
        }
        
        property("Joining two optionals together with same target should yield same result") <- forAll { (int : Int) in
            let joinedOptional = optionalHead.choice(defaultHead)
            return Option.eq(Int.order).eqv(joinedOptional.getMaybe(Either.left([int])),
                                           joinedOptional.getMaybe(Either.right(int)))
        }
    }
    
    func testOptionalComposition() {
        property("Optional + Optional::identity") <- forAll { (array : ArrayOf<Int>, def : Int) in
            return (optionalHead + Bow.Optional<Int, Int>.identity()).getMaybe(array.getArray).getOrElse(def) == optionalHead.getMaybe(array.getArray).getOrElse(def)
        }
        
        property("Optional + Iso::identity") <- forAll { (array : ArrayOf<Int>, def : Int) in
            return (optionalHead + Iso<Int, Int>.identity()).getMaybe(array.getArray).getOrElse(def) == optionalHead.getMaybe(array.getArray).getOrElse(def)
        }
        
        property("Optional + Lens::identity") <- forAll { (array : ArrayOf<Int>, def : Int) in
            return (optionalHead + Lens<Int, Int>.identity()).getMaybe(array.getArray).getOrElse(def) == optionalHead.getMaybe(array.getArray).getOrElse(def)
        }
        
        property("Optional + Prism::identity") <- forAll { (array : ArrayOf<Int>, def : Int) in
            return (optionalHead + Prism<Int, Int>.identity()).getMaybe(array.getArray).getOrElse(def) == optionalHead.getMaybe(array.getArray).getOrElse(def)
        }
        
        property("Optional + Getter::identity") <- forAll { (array : ArrayOf<Int>) in
            return (optionalHead + Getter<Int, Int>.identity()).getAll(array.getArray).asArray == optionalHead.getMaybe(array.getArray).fold(constant([]), { x in [x] })
        }
        
        let nonEmptyGenerator = ArrayOf<Int>.arbitrary.suchThat { array in array.getArray.count > 0 }
        property("Optional + Setter::identity") <- forAll(nonEmptyGenerator, Int.arbitrary) { (array : ArrayOf<Int>, def : Int) in
            return (optionalHead + Setter<Int, Int>.identity()).set(array.getArray, def) == optionalHead.set(array.getArray, def)
        }
        
        property("Optional + Fold::identity") <- forAll { (array : ArrayOf<Int>) in
            return (optionalHead + Fold<Int, Int>.identity()).getAll(array.getArray).asArray == optionalHead.getMaybe(array.getArray).fold(constant([]), { x in [x] })
        }
        
        property("Optional + Traversal::identity") <- forAll { (array : ArrayOf<Int>) in
            return (optionalHead + Traversal<Int, Int>.identity()).getAll(array.getArray).asArray == optionalHead.getMaybe(array.getArray).fold(constant([]), { x in [x] })
        }
    }
}
