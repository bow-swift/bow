import XCTest
@testable import Bow

class LensTest: XCTestCase {
    
    func testLensLaws() {
        LensLaws.check(lens: tokenLens, eqA: Token.eq, eqB: String.order)
    }
    
    func testOptionalLaws() {
        OptionalLaws.check(optional: tokenLens.asOptional(), eqA: Token.eq, eqB: String.order)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: tokenLens.asSetter(), eqA: Token.eq)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: tokenLens.asTraversal(), eqA: Token.eq, eqB: String.order)
    }
}
