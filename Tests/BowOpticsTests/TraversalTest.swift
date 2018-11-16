import XCTest
import SwiftCheck
@testable import Bow
@testable import BowOptics

class TraversalTest: XCTestCase {
    let listKTraversal = Traversal<Int, Int>.from(traverse: ListK<Int>.traverse())
    let listKGen : Gen<ListKOf<Int>> = ArrayOf<Int>.arbitrary.map{ array in array.getArray.k() }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: listKTraversal,
                            eqA: ListK<Int>.eq(Int.order),
                            eqB: Int.order,
                            generatorA: listKGen)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: listKTraversal.asSetter(),
                         eqA: ListK<Int>.eq(Int.order),
                         generatorA: listKGen)
    }
    
    func testTraversalAsFold() {
        property("Traversal as Fold: size") <- forAll { (array : ArrayOf<Int>) in
            return self.listKTraversal.asFold().size(array.getArray.k()) == array.getArray.count
        }
        
        property("Traversal as Fold: nonEmpty") <- forAll { (array : ArrayOf<Int>) in
            return self.listKTraversal.asFold().nonEmpty(array.getArray.k()) == !array.getArray.isEmpty
        }
        
        property("Traversal as Fold: isEmpty") <- forAll { (array : ArrayOf<Int>) in
            return self.listKTraversal.asFold().isEmpty(array.getArray.k()) == array.getArray.isEmpty
        }
        
        property("Traversal as Fold: getAll") <- forAll { (array : ArrayOf<Int>) in
            return ListK.eq(Int.order).eqv(self.listKTraversal.asFold().getAll(array.getArray.k()),
                                           array.getArray.k())
        }
        
        property("Traversal as Fold: combineAll") <- forAll { (array : ArrayOf<Int>) in
            return self.listKTraversal.asFold().combineAll(Int.sumMonoid, array.getArray.k()) == array.getArray.reduce(0, +)
        }
        
        property("Traversal as Fold: fold") <- forAll { (array : ArrayOf<Int>) in
            return self.listKTraversal.asFold().combineAll(Int.sumMonoid, array.getArray.k()) == array.getArray.reduce(0, +)
        }
        
        property("Traversal as Fold: headOption") <- forAll { (array : ArrayOf<Int>) in
            return Option.eq(Int.order).eqv(
                self.listKTraversal.asFold().headOption(array.getArray.k()),
                Option.fromOption(array.getArray.first))
        }
        
        property("Traversal as Fold: lastOption") <- forAll { (array : ArrayOf<Int>) in
            return Option.eq(Int.order).eqv(
                self.listKTraversal.asFold().lastOption(array.getArray.k()),
                Option.fromOption(array.getArray.last))
        }
    }
    
    func testTraversalProperties() {
        property("Getting all targets of a traversal") <- forAll { (array : ArrayOf<Int>) in
            return ListK.eq(Int.order).eqv(self.listKTraversal.getAll(array.getArray.k()),
                                           array.getArray.k())
        }
        
        property("Folding all the values from a traversal") <- forAll { (array : ArrayOf<Int>) in
            return self.listKTraversal.fold(Int.sumMonoid, array.getArray.k()) ==
                array.getArray.reduce(0, +)
        }
        
        property("Combining all the values from a traversal") <- forAll { (array : ArrayOf<Int>) in
            return self.listKTraversal.fold(Int.sumMonoid, array.getArray.k()) ==
                array.getArray.reduce(0, +)
        }
        
        property("Find a target in a traversal") <- forAll { (array : ArrayOf<Int>) in
            return Option.eq(Int.order).eqv(
                self.listKTraversal.find(array.getArray.k(), { x in x > 10 }),
                Option.fromOption(array.getArray.filter { x in x > 10 }.first))
        }
        
        property("Size of a traversal") <- forAll { (array : ArrayOf<Int>) in
            return self.listKTraversal.size(array.getArray.k()) == array.getArray.count
        }
    }
    
    func testTraversalComposition() {
        property("Traversal + Traversal::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.listKTraversal + Traversal<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.listKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Iso::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.listKTraversal + Iso<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.listKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Lens::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.listKTraversal + Lens<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.listKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Prism::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.listKTraversal + Prism<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.listKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Optional::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.listKTraversal + BowOptics.Optional<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.listKTraversal.getAll(array.getArray.k()).asArray
        }
        
        property("Traversal + Setter::identity") <- forAll { (array : ArrayOf<Int>, value : Int) in
            return (self.listKTraversal + Setter<Int, Int>.identity()).set(array.getArray.k(), value).fix().asArray == self.listKTraversal.set(array.getArray.k(), value).fix().asArray
        }
        
        property("Traversal + Fold::identity") <- forAll { (array : ArrayOf<Int>) in
            return (self.listKTraversal + Fold<Int, Int>.identity()).getAll(array.getArray.k()).asArray == self.listKTraversal.getAll(array.getArray.k()).asArray
        }
    }
}
