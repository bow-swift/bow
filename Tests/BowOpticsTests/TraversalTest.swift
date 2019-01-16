import XCTest
import SwiftCheck
@testable import Bow
@testable import BowOptics

class TraversalTest: XCTestCase {
    let arrayKTraversal = Traversal<Int, Int>.from(traverse: ArrayK<Int>.traverse())
    let arrayKGen : Gen<ArrayKOf<Int>> = ArrayOf<Int>.arbitrary.map{ array in array.getArray.k() }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: arrayKTraversal,
                            eqA: ArrayK<Int>.eq(Int.order),
                            eqB: Int.order,
                            generatorA: arrayKGen)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: arrayKTraversal.asSetter(),
                         eqA: ArrayK<Int>.eq(Int.order),
                         generatorA: arrayKGen)
    }
    
    func testTraversalAsFold() {
        property("Traversal as Fold: size") <- forAll { (array : ArrayOf<Int>) in
            return self.arrayKTraversal.asFold().size(array.getArray.k()) == array.getArray.count
        }
        
        property("Traversal as Fold: nonEmpty") <- forAll { (array : ArrayOf<Int>) in
            return self.arrayKTraversal.asFold().nonEmpty(array.getArray.k()) == !array.getArray.isEmpty
        }
        
        property("Traversal as Fold: isEmpty") <- forAll { (array : ArrayOf<Int>) in
            return self.arrayKTraversal.asFold().isEmpty(array.getArray.k()) == array.getArray.isEmpty
        }
        
        property("Traversal as Fold: getAll") <- forAll { (array : ArrayOf<Int>) in
            return ArrayK.eq(Int.order).eqv(self.arrayKTraversal.asFold().getAll(array.getArray.k()),
                                           array.getArray.k())
        }
        
        property("Traversal as Fold: combineAll") <- forAll { (array : ArrayOf<Int>) in
            return self.arrayKTraversal.asFold().combineAll(Int.sumMonoid, array.getArray.k()) == array.getArray.reduce(0, +)
        }
        
        property("Traversal as Fold: fold") <- forAll { (array : ArrayOf<Int>) in
            return self.arrayKTraversal.asFold().combineAll(Int.sumMonoid, array.getArray.k()) == array.getArray.reduce(0, +)
        }
        
        property("Traversal as Fold: headOption") <- forAll { (array : ArrayOf<Int>) in
            return Option.eq(Int.order).eqv(
                self.arrayKTraversal.asFold().headOption(array.getArray.k()),
                Option.fromOptional(array.getArray.first))
        }
        
        property("Traversal as Fold: lastOption") <- forAll { (array : ArrayOf<Int>) in
            return Option.eq(Int.order).eqv(
                self.arrayKTraversal.asFold().lastOption(array.getArray.k()),
                Option.fromOptional(array.getArray.last))
        }
    }
    
    func testTraversalProperties() {
        property("Getting all targets of a traversal") <- forAll { (array : ArrayOf<Int>) in
            return ArrayK.eq(Int.order).eqv(self.arrayKTraversal.getAll(array.getArray.k()),
                                           array.getArray.k())
        }
        
        property("Folding all the values from a traversal") <- forAll { (array : ArrayOf<Int>) in
            return self.arrayKTraversal.fold(Int.sumMonoid, array.getArray.k()) ==
                array.getArray.reduce(0, +)
        }
        
        property("Combining all the values from a traversal") <- forAll { (array : ArrayOf<Int>) in
            return self.arrayKTraversal.fold(Int.sumMonoid, array.getArray.k()) ==
                array.getArray.reduce(0, +)
        }
        
        property("Find a target in a traversal") <- forAll { (array : ArrayOf<Int>) in
            return Option.eq(Int.order).eqv(
                self.arrayKTraversal.find(array.getArray.k(), { x in x > 10 }),
                Option.fromOptional(array.getArray.filter { x in x > 10 }.first))
        }
        
        property("Size of a traversal") <- forAll { (array : ArrayOf<Int>) in
            return self.arrayKTraversal.size(array.getArray.k()) == array.getArray.count
        }
    }
    
    func testTraversalComposition() {
        property("Traversal + Traversal::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.arrayKTraversal + Traversal<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.arrayKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Iso::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.arrayKTraversal + Iso<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.arrayKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Lens::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.arrayKTraversal + Lens<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.arrayKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Prism::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.arrayKTraversal + Prism<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.arrayKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Optional::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.arrayKTraversal + BowOptics.Optional<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.arrayKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Setter::identity") <- forAll { (array : ArrayOf<Int>, value : Int) in
            return (self.arrayKTraversal + Setter<Int, Int>.identity()).set(array.getArray.k(), value).fix().asArray == self.arrayKTraversal.set(array.getArray.k(), value).fix().asArray
        }
        
        property("Traversal + Fold::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.arrayKTraversal + Fold<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.arrayKTraversal.getAll(array.getArray.k()).asArray
        }
    }
}
