import XCTest
@testable import Bow

class OptionalTest: XCTestCase {
    
    func testOptionalLaws() {
        OptionalLaws.check(optional: Bow.Optional<String, String>.identity(), eqA: String.order, eqB: String.order)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: Bow.Optional<String, String>.identity().asSetter(), eqA: String.order)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: Bow.Optional<String, String>.identity().asTraversal(), eqA: String.order, eqB: String.order)
    }
}
