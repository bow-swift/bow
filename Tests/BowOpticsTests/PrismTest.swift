import XCTest
import SwiftCheck
import Bow
import BowOptics
import BowOpticsLaws
import BowLaws

class PrismTest: XCTestCase {
    
    func testPrismLaws() {
        PrismLaws.check(prism: StringStyle.prism)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: StringStyle.prism.asSetter)
    }
    
    func testAffineTraversalLaws() {
        AffineTraversalLaws.check(affineTraversal: StringStyle.prism.asAffineTraversal)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: StringStyle.prism.asTraversal)
    }
    
    func testPrismAsFold() {
        property("Prism as Fold: size") <~ forAll { (sum: SumType) in
            return SumType.prism.asFold.size(sum) == Option.fix(SumType.prism.getOption(sum).map(constant(1))).getOrElse(0)
        }

        property("Prism as Fold: nonEmpty") <~ forAll { (sum: SumType) in
            return SumType.prism.asFold.nonEmpty(sum) == SumType.prism.getOption(sum).isDefined
        }

        property("Prism as Fold: isEmpty") <~ forAll { (sum: SumType) in
            return SumType.prism.asFold.isEmpty(sum) == SumType.prism.getOption(sum).isEmpty
        }

        property("Prism as Fold: getAll") <~ forAll { (sum: SumType) in
            return SumType.prism.asFold.getAll(sum) == SumType.prism.getOption(sum).toArray().k()
        }

        property("Prism as Fold: combineAll") <~ forAll { (sum: SumType) in
            return SumType.prism.asFold.combineAll(sum) == SumType.prism.getOption(sum).fold(constant(String.empty()), id)
        }

        property("Prism as Fold: fold") <~ forAll { (sum: SumType) in
            return SumType.prism.asFold.fold(sum) == SumType.prism.getOption(sum).fold(constant(String.empty()), id)
        }

        property("Prism as Fold: headOption") <~ forAll { (sum: SumType) in
            return SumType.prism.asFold.headOption(sum) == SumType.prism.getOption(sum)
        }

        property("Prism as Fold: lastOption") <~ forAll { (sum: SumType) in
            return SumType.prism.asFold.lastOption(sum) == SumType.prism.getOption(sum)
        }
    }

    func testPrismProperties() {
        let sumAGen: Gen<SumType> = String.arbitrary.map(SumType.a)

        property("Joining two prisms with the same target should yield the same result") <~ forAll { (sum: SumType) in
            return (SumType.prism + StringStyle.prism).getOption(sum) == SumType.prism.getOption(sum).flatMap(StringStyle.prism.getOption)
        }

        property("Checking if a prism exists with a target") <~ forAll { (a: SumType, b: SumType) in
            return Prism<SumType, SumType>.only(a).isEmpty(b) == (a == b)
        }

        property("Checking if there is no target") <~ forAll { (sum: SumType) in
            return SumType.prism.isEmpty(sum) == !sum.isA
        }

        property("Checking if a target exists") <~ forAll { (sum: SumType) in
            return SumType.prism.nonEmpty(sum) == sum.isA
        }

        property("Setting a target on a prism should set the correct target") <~ forAll(sumAGen, String.arbitrary) { (sum: SumType, str: String) in
            return SumType.prism.setOption(sum, str) == Option.some(SumType.a(str))
        }

        property("Finding a target using a predicate within a Prism should be wrapped in the correct option result") <~ forAll { (sum: SumType, predicate: Bool) in
            return SumType.prism.find(sum, constant(predicate)).fold(constant(false), constant(true)) == (predicate && sum.isA)
        }

        property("Checking existence predicate over the target should result in same result as predicate") <~ forAll { (sum: SumType, predicate: Bool) in
            return SumType.prism.exists(sum, constant(predicate)) == (predicate && sum.isA)
        }

        property("Checking satisfaction of predicate over the target should result in opposite result as predicate") <~ forAll { (sum: SumType, predicate: Bool) in
            return SumType.prism.all(sum, constant(predicate)) == (predicate || !sum.isA)
        }
    }

    func testPrismComposition() {
        property("Prism + Prism::identity") <~ forAll { (sum: SumType, def: String) in
            return (SumType.prism + Prism<String, String>.identity).getOption(sum).getOrElse(def) == SumType.prism.getOption(sum).getOrElse(def)
        }

        property("Prism + Iso::identity") <~ forAll { (sum: SumType, def: String) in
            return (SumType.prism + Iso<String, String>.identity).getOption(sum).getOrElse(def) == SumType.prism.getOption(sum).getOrElse(def)
        }

        property("Prism + Lens::identity") <~ forAll { (sum: SumType, def: String) in
            return (SumType.prism + Lens<String, String>.identity).getOption(sum).getOrElse(def) == SumType.prism.getOption(sum).getOrElse(def)
        }

        property("Prism + AffineTraversal::identity") <~ forAll { (sum: SumType, def: String) in
            return (SumType.prism + AffineTraversal<String, String>.identity).getOption(sum).getOrElse(def) == SumType.prism.getOption(sum).getOrElse(def)
        }

        property("Prism + Fold::identity") <~ forAll { (sum: SumType) in
            return (SumType.prism + Fold<String, String>.identity).getAll(sum).asArray == SumType.prism.getOption(sum).fold(constant([]), { a in [a] })
        }

        property("Prism + Traversal::identity") <~ forAll { (sum: SumType) in
            return (SumType.prism + Traversal<String, String>.identity).getAll(sum).asArray == SumType.prism.getOption(sum).fold(constant([]), { a in [a] })
        }

        property("Prism + Setter::identity") <~ forAll { (sum: SumType, def: String) in
            return (SumType.prism + Setter<String, String>.identity).set(sum, def) == SumType.prism.set(sum, def)
        }
    }

    func testAutoDerivatePrism_WithoutAssociatedTypes() {
        let prism = Authentication.prism(for: Authentication.unkown)
        XCTAssertTrue(prism.getOption(.unkown).isDefined)
    }

    func testAutoDerivatePrism_WithAssociatedTypes() {
        let prism = Authentication.prism(for: Authentication.authorized)
        let result = prism.getOption(.authorized(8, "information")).toOptional() ?? (0, "")
        XCTAssertTrue(result == (8, "information"))
    }
    
    func testAutoDerivatePrism_WithComplexAssociatedTypes() {
        let auto = ParentAction.prism(for: ParentAction.child)
        let action = ParentAction.child(child: .changeColor)
        let c1 = auto.getOptional(action)
        XCTAssertEqual(c1, .changeColor)
    }

    func testAutoDerivatePrism_WithLabeledAssociatedTypes() {
        let prism = Authentication.prism(for: Authentication.requested)
        let result = prism.getOption(.requested(1, info: "information")).toOptional() ?? (0, "")
        XCTAssertTrue(result == (1, "information"))
    }

    #if !os(Linux)
    enum EnumLabeled: AutoPrism {
        case labeled(label: String)
        case labeled(anotherLabel: String)
    }
    
    func testAutoDerivatePrism_SameCaseName_DifferentLabeledAssociatedTypes() {
        let labeledPrism = EnumLabeled.prism(for: EnumLabeled.labeled(label:))
        let labelResult = labeledPrism.getOption(.labeled(label: "7")).toOptional()
        let anotherLabelResult = labeledPrism.getOption(.labeled(anotherLabel: "7")).toOptional()

        XCTAssertEqual(labelResult, "7")
        XCTAssertNil(anotherLabelResult)
    }
    #else
    func testAutoDerivatePrism_SameCaseName_DifferentLabeledAssociatedTypes() {
        XCTAssertTrue(true)
    }
    #endif
}
