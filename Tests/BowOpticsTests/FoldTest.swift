import XCTest
import SwiftCheck
import Bow
import BowOptics
import BowLaws

class FoldTest: XCTestCase {
    func testFoldProperties() {
        property("Fold select an array that contains one") <~ forAll { (array: NEA<Int>) in
            let select = Fold<Array<Int>, Array<Int>>.select({ array in array.contains(1) })
            return select.getAll(array.all()).asArray.first == (array.contains(element: 1) ? array.all() : nil)
        }
        
        property("Folding an array of ints") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.foldK.fold(array) == array.asArray.reduce(0, +)
        }
        
        property("Folding an array is equivalent to combineAll") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.foldK.combineAll(array) == array.asArray.reduce(0, +)
        }
        
        property("Folding and mapping an array of strings") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<String>.foldK.foldMap(array.map(String.init)^, { s in Int(s)! }) == array^.asArray.reduce(0, +)
        }
        
        property("Get all targets") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.foldK.getAll(array) == array
        }
        
        property("Get size of the fold") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.foldK.size(array) == array.count
        }
        
        property("Find first element matching predicate") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.foldK.find(array, { x in x > 10 }) ==
                array.asArray.filter{ x in x > 10 }.first.toOption()
        }
        
        property("Checking existence of a target") <~ forAll { (array: ArrayK<Int>, predicate: Bool) in
            return ArrayK<Int>.foldK.exists(array, constant(predicate)) == predicate || array.isEmpty
        }
        
        property("Check if all targets match the predicate") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.foldK.forAll(array, { x in x % 2 == 0 }) ==
                array.asArray.map { x in x % 2 == 0 }.reduce(false, or)
        }
        
        property("Check if there is no target") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.foldK.isEmpty(array) == array.isEmpty
        }
        
        property("Check if there is a target") <~ forAll { (array: ArrayK<Int>) in
            return ArrayK<Int>.foldK.nonEmpty(array) == !array.isEmpty
        }
    }
    
    func testFoldComposition() {
        property("Fold + Fold::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.foldK + Fold<Int, Int>.identity).getAll(array) == ArrayK<Int>.foldK.getAll(array)
        }
        
        property("Fold + Iso::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.foldK + Iso<Int, Int>.identity).getAll(array) == ArrayK<Int>.foldK.getAll(array)
        }
        
        property("Fold + Lens::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.foldK + Lens<Int, Int>.identity).getAll(array) == ArrayK<Int>.foldK.getAll(array)
        }
        
        property("Fold + Prism::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.foldK + Prism<Int, Int>.identity).getAll(array) == ArrayK<Int>.foldK.getAll(array)
        }
        
        property("Fold + Getter::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.foldK + Getter<Int, Int>.identity).getAll(array) == ArrayK<Int>.foldK.getAll(array)
        }
        
        property("Fold + AffineTraversal::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.foldK + AffineTraversal<Int, Int>.identity).getAll(array) == ArrayK<Int>.foldK.getAll(array)
        }
        
        property("Fold + Traversal::identity") <~ forAll { (array: ArrayK<Int>) in
            return (ArrayK<Int>.foldK + Traversal<Int, Int>.identity).getAll(array) == ArrayK<Int>.foldK.getAll(array)
        }
    }
}
