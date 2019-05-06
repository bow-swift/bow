import XCTest
import SwiftCheck
@testable import Bow
@testable import BowOptics

class FoldTest: XCTestCase {
    let nonEmptyListGen = Array<Int>.arbitrary.suchThat({ array in array.count > 0 })

    func intFold<F: Foldable>() -> Fold<Kind<F, Int>, Int> {
        return Fold<Int, Int>.fromFoldable()
    }

    func stringFold<F: Foldable>() -> Fold<Kind<F, String>, String> {
        return Fold<String, String>.fromFoldable()
    }

    func testFoldProperties() {
        property("Fold select an array that contains one") <- forAll(self.nonEmptyListGen) { (array: Array<Int>) in
            let select = Fold<Array<Int>, Int>.select({ array in array.contains(1) })
            return select.getAll(array).asArray.first == (array.contains(1) ? array : nil)
        }
        
        property("Folding an array of ints") <- forAll { (array: Array<Int>) in
            return self.intFold().fold(array.k()) == array.reduce(0, +)
        }
        
        property("Folding an array is equivalent to combineAll") <- forAll { (array: Array<Int>) in
            return self.intFold().combineAll(array.k()) == array.reduce(0, +)
        }
        
        property("Folding and mapping an array of strings") <- forAll { (array: Array<Int>) in
            return self.stringFold().foldMap(array.map(String.init).k(), { s in Int(s)! }) == array.reduce(0, +)
        }
        
        property("Get all targets") <- forAll { (array: Array<Int>) in
            return self.intFold().getAll(array.k()) == array.k()
        }
        
        property("Get size of the fold") <- forAll { (array: Array<Int>) in
            return self.intFold().size(array.k()) == array.count
        }
        
        property("Find first element matching predicate") <- forAll { (array: Array<Int>) in
            return self.intFold().find(array.k(), { x in x > 10 }) ==
                Option.fromOptional(array.filter{ x in x > 10 }.first)
        }
        
        property("Checking existence of a target") <- forAll(self.nonEmptyListGen, Bool.arbitrary) { (array: Array<Int>, predicate: Bool) in
            return self.intFold().exists(array.k(), constant(predicate)) == predicate
        }
        
        property("Check if all targets match the predicate") <- forAll { (array : Array<Int>) in
            return self.intFold().forAll(array.k(), { x in x % 2 == 0 }) ==
                array.map { x in x % 2 == 0 }.reduce(true, and)
        }
        
        property("Check if there is no target") <- forAll { (array: Array<Int>) in
            return self.intFold().isEmpty(array.k()) == array.isEmpty
        }
        
        property("Check if there is a target") <- forAll { (array: Array<Int>) in
            return self.intFold().nonEmpty(array.k()) == !array.isEmpty
        }
    }
    
    func testFoldComposition() {
        property("Fold + Fold::identity") <- forAll { (array: Array<Int>) in
            return (self.intFold() + Fold<Int, Int>.identity()).getAll(array.k()).asArray == self.intFold().getAll(array.k()).asArray
        }
        
        property("Fold + Iso::identity") <- forAll { (array: Array<Int>) in
            return (self.intFold() + Iso<Int, Int>.identity()).getAll(array.k()).asArray == self.intFold().getAll(array.k()).asArray
        }
        
        property("Fold + Lens::identity") <- forAll { (array: Array<Int>) in
            return (self.intFold() + Lens<Int, Int>.identity()).getAll(array.k()).asArray == self.intFold().getAll(array.k()).asArray
        }
        
        property("Fold + Prism::identity") <- forAll { (array: Array<Int>) in
            return (self.intFold() + Prism<Int, Int>.identity()).getAll(array.k()).asArray == self.intFold().getAll(array.k()).asArray
        }
        
        property("Fold + Getter::identity") <- forAll { (array: Array<Int>) in
            return (self.intFold() + Getter<Int, Int>.identity()).getAll(array.k()).asArray == self.intFold().getAll(array.k()).asArray
        }
        
        property("Fold + Optional::identity") <- forAll { (array: Array<Int>) in
            return (self.intFold() + BowOptics.Optional<Int, Int>.identity()).getAll(array.k()).asArray == self.intFold().getAll(array.k()).asArray
        }
        
        property("Fold + Traversal::identity") <- forAll { (array: Array<Int>) in
            return (self.intFold() + Traversal<Int, Int>.identity()).getAll(array.k()).asArray == self.intFold().getAll(array.k()).asArray
        }
    }
}
