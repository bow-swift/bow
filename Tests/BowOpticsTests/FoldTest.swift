import XCTest
import SwiftCheck
@testable import Bow
@testable import BowOptics

class FoldTest : XCTestCase {
    let intFold = Fold<Int, Int>.from(foldable: ArrayK<Int>.foldable())
    let stringFold = Fold<String, String>.from(foldable: ArrayK<String>.foldable())
    let nonEmptyListGen = ArrayOf<Int>.arbitrary.suchThat({ array in array.getArray.count > 0 })
    
    func testFoldProperties() {
        property("Fold select a list that contains one") <- forAll(self.nonEmptyListGen) { (array : ArrayOf<Int>) in
            let select = Fold<Array<Int>, Int>.select({ array in array.contains(1) })
            return select.getAll(array.getArray).asArray.first == (array.getArray.contains(1) ? array : nil)?.getArray
        }
        
        property("Folding a list of ints") <- forAll { (array : ArrayOf<Int>) in
            return self.intFold.fold(Int.sumMonoid, array.getArray.k()) == array.getArray.reduce(0, +)
        }
        
        property("Folding a list is equivalent to combineAll") <- forAll { (array : ArrayOf<Int>) in
            return self.intFold.combineAll(Int.sumMonoid, array.getArray.k()) == array.getArray.reduce(0, +)
        }
        
        property("Folding and mapping a list of strings") <- forAll { (array : ArrayOf<Int>) in
            return self.stringFold.foldMap(Int.sumMonoid, array.getArray.map(String.init).k(), { s in Int(s)! }) == array.getArray.reduce(0, +)
        }
        
        property("Get all targets") <- forAll { (array : ArrayOf<Int>) in
            return ArrayK.eq(Int.order).eqv(self.intFold.getAll(array.getArray.k()),
                                           array.getArray.k())
        }
        
        property("Get size of the fold") <- forAll { (array : ArrayOf<Int>) in
            return self.intFold.size(array.getArray.k()) == array.getArray.count
        }
        
        property("Find first element matching predicate") <- forAll { (array : ArrayOf<Int>) in
            return Option.eq(Int.order).eqv(self.intFold.find(array.getArray.k(), { x in x > 10 }),
                                           Option.fromOptional(array.getArray.filter{ x in x > 10 }.first))
        }
        
        property("Checking existence of a target") <- forAll(self.nonEmptyListGen, Bool.arbitrary) { (array : ArrayOf<Int>, predicate : Bool) in
            return self.intFold.exists(array.getArray.k(), constant(predicate)) == predicate
        }
        
        property("Check if all targets match the predicate") <- forAll { (array : ArrayOf<Int>) in
            return self.intFold.forAll(array.getArray.k(), { x in x % 2 == 0 }) ==
                array.getArray.map { x in x % 2 == 0 }.reduce(true, and)
        }
        
        property("Check if there is no target") <- forAll { (array : ArrayOf<Int>) in
            return self.intFold.isEmpty(array.getArray.k()) == array.getArray.isEmpty
        }
        
        property("Check if there is a target") <- forAll { (array : ArrayOf<Int>) in
            return self.intFold.nonEmpty(array.getArray.k()) == !array.getArray.isEmpty
        }
    }
    
    func testFoldComposition() {
        property("Fold + Fold::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.intFold + Fold<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.intFold.getAll(array.getArray.k()).asArray
        }
        
        property("Fold + Iso::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.intFold + Iso<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.intFold.getAll(array.getArray.k()).asArray
        }
        
        property("Fold + Lens::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.intFold + Lens<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.intFold.getAll(array.getArray.k()).asArray
        }
        
        property("Fold + Prism::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.intFold + Prism<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.intFold.getAll(array.getArray.k()).asArray
        }
        
        property("Fold + Getter::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.intFold + Getter<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.intFold.getAll(array.getArray.k()).asArray
        }
        
        property("Fold + Optional::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.intFold + BowOptics.Optional<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.intFold.getAll(array.getArray.k()).asArray
        }
        
        property("Fold + Traversal::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.intFold + Traversal<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.intFold.getAll(array.getArray.k()).asArray
        }
    }
}
