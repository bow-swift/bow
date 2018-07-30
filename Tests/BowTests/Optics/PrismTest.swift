import XCTest
import SwiftCheck
@testable import Bow

class PrismTest: XCTestCase {
    
    func testPrismLaws() {
        PrismLaws.check(prism: stringPrism, eqA: String.order, eqB: String.order)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: stringPrism.asSetter(), eqA: String.order, generatorA: String.arbitrary)
    }
    
    func testOptionalLaws() {
        OptionalLaws.check(optional: stringPrism.asOptional(), eqA: String.order, eqB: String.order)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: stringPrism.asTraversal(), eqA: String.order, eqB: String.order, generatorA: String.arbitrary)
    }
    
    func testPrismAsFold() {
        property("Prism as Fold: size") <- forAll { (sum : SumType) in
            return sumPrism.asFold().size(sum) == sumPrism.getMaybe(sum).map(constant(1)).getOrElse(0)
        }
        
        property("Prism as Fold: nonEmpty") <- forAll { (sum : SumType) in
            return sumPrism.asFold().nonEmpty(sum) == sumPrism.getMaybe(sum).isDefined
        }
        
        property("Prism as Fold: isEmpty") <- forAll { (sum : SumType) in
            return sumPrism.asFold().isEmpty(sum) == sumPrism.getMaybe(sum).isEmpty
        }
        
        property("Prism as Fold: getAll") <- forAll { (sum : SumType) in
            return ListK.eq(String.order).eqv(sumPrism.asFold().getAll(sum),
                                              sumPrism.getMaybe(sum).toList().k())
        }
        
        property("Prism as Fold: combineAll") <- forAll { (sum : SumType) in
            return sumPrism.asFold().combineAll(String.concatMonoid, sum) == sumPrism.getMaybe(sum).fold(constant(String.concatMonoid.empty), id)
        }
        
        property("Prism as Fold: fold") <- forAll { (sum : SumType) in
            return sumPrism.asFold().fold(String.concatMonoid, sum) == sumPrism.getMaybe(sum).fold(constant(String.concatMonoid.empty), id)
        }
        
        property("Prism as Fold: headMaybe") <- forAll { (sum : SumType) in
            return Maybe.eq(String.order).eqv(sumPrism.asFold().headMaybe(sum),
                                              sumPrism.getMaybe(sum))
        }
        
        property("Prism as Fold: lastMaybe") <- forAll { (sum : SumType) in
            return Maybe.eq(String.order).eqv(sumPrism.asFold().lastMaybe(sum),
                                              sumPrism.getMaybe(sum))
        }
    }
    
    let sumAGen : Gen<SumType> = String.arbitrary.map(SumType.a)
    
    func testPrismProperties() {
        property("Joining two prisms with the same target should yield the same result") <- forAll { (sum : SumType) in
            let eq = Maybe.eq(String.order)
            return eq.eqv((sumPrism + stringPrism).getMaybe(sum),
                          sumPrism.getMaybe(sum).flatMap(stringPrism.getMaybe))
        }

        property("Checking if a prism exists with a target") <- forAll { (a : SumType, b : SumType, bool : Bool) in
            return Prism<SumType, SumType>.only(a, ConstantEq(constant: bool)).isEmpty(b) == bool
        }
        
        property("Checking if there is no target") <- forAll { (sum : SumType) in
            return sumPrism.isEmpty(sum) == !sum.isA
        }
        
        property("Checking if a target exists") <- forAll { (sum : SumType) in
            return sumPrism.nonEmpty(sum) == sum.isA
        }
        
        property("Setting a target on a prism should set the correct target") <- forAll(self.sumAGen, String.arbitrary) { (sum : SumType, str : String) in
            return Maybe.eq(SumType.eq).eqv(sumPrism.setMaybe(sum, str),
                                            Maybe.some(SumType.a(str)))
        }
        
        property("Finding a target using a predicate within a Prism should be wrapped in the correct option result") <- forAll { (sum : SumType, predicate : Bool) in
            return sumPrism.find(sum, constant(predicate)).fold(constant(false), constant(true)) == (predicate && sum.isA)
        }
        
        property("Checking existence predicate over the target should result in same result as predicate") <- forAll { (sum : SumType, predicate : Bool) in
            return sumPrism.exists(sum, constant(predicate)) == (predicate && sum.isA)
        }
        
        property("Checking satisfaction of predicate over the target should result in opposite result as predicate") <- forAll { (sum : SumType, predicate : Bool) in
            return sumPrism.all(sum, constant(predicate)) == (predicate || !sum.isA)
        }
    }
    
    func testPrismComposition() {
        property("Prism + Prism::identity") <- forAll { (sum : SumType, def: String) in
            return (sumPrism + Prism<String, String>.identity()).getMaybe(sum).getOrElse(def) == sumPrism.getMaybe(sum).getOrElse(def)
        }
        
        property("Prism + Iso::identity") <- forAll { (sum : SumType, def: String) in
            return (sumPrism + Iso<String, String>.identity()).getMaybe(sum).getOrElse(def) == sumPrism.getMaybe(sum).getOrElse(def)
        }
        
        property("Prism + Lens::identity") <- forAll { (sum : SumType, def: String) in
            return (sumPrism + Lens<String, String>.identity()).getMaybe(sum).getOrElse(def) == sumPrism.getMaybe(sum).getOrElse(def)
        }
        
        property("Prism + Optional::identity") <- forAll { (sum : SumType, def: String) in
            return (sumPrism + Bow.Optional<String, String>.identity()).getMaybe(sum).getOrElse(def) == sumPrism.getMaybe(sum).getOrElse(def)
        }
        
        property("Prism + Fold::identity") <- forAll { (sum : SumType) in
            return (sumPrism + Fold<String, String>.identity()).getAll(sum).asArray == sumPrism.getMaybe(sum).fold(constant([]), { a in [a] })
        }
        
        property("Prism + Traversal::identity") <- forAll { (sum : SumType) in
            return (sumPrism + Traversal<String, String>.identity()).getAll(sum).asArray == sumPrism.getMaybe(sum).fold(constant([]), { a in [a] })
        }
        
        property("Prism + Setter::identity") <- forAll { (sum : SumType, def: String) in
            return (sumPrism + Setter<String, String>.identity()).set(sum, def) == sumPrism.set(sum, def)
        }
    }
}

fileprivate class ConstantEq : Eq {
    typealias A = SumType
    private let constant : Bool
    
    init(constant : Bool) {
        self.constant = constant
    }
    
    func eqv(_ a: SumType, _ b: SumType) -> Bool {
        return constant
    }
}
