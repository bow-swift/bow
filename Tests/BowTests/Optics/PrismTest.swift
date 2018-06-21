import XCTest
@testable import Bow

class PrismTest: XCTestCase {
    
    func testPrismLaws() {
        PrismLaws.check(prism: stringPrism, eqA: String.order, eqB: String.order)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: stringPrism.asSetter(), eqA: String.order)
    }
    
    func testOptionalLaws() {
        OptionalLaws.check(optional: stringPrism.asOptional(), eqA: String.order, eqB: String.order)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: stringPrism.asTraversal(), eqA: String.order, eqB: String.order)
    }
}
