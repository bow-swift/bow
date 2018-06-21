import XCTest
@testable import Bow

class IsoTest: XCTestCase {
    
    func testIsoLaws() {
        IsoLaws.check(iso: tokenIso, eqA: Token.eq, eqB: String.order)
    }
    
    func testPrismLaws() {
        PrismLaws.check(prism: tokenIso.asPrism(), eqA: Token.eq, eqB: String.order)
    }
    
    func testLensLaws() {
        LensLaws.check(lens: tokenIso.asLens(), eqA: Token.eq, eqB: String.order)
    }
    
    func testOptionalLaws() {
        OptionalLaws.check(optional: tokenIso.asOptional(), eqA: Token.eq, eqB: String.order)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: tokenIso.asSetter(), eqA: Token.eq)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: tokenIso.asTraversal(), eqA: Token.eq, eqB: String.order)
    }
}
