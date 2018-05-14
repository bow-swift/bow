import XCTest
@testable import Bow

class SetterTest: XCTestCase {
    
    func testSetterLaws() {
        SetterLaws.check(setter: tokenSetter, eqA: Token.eq)
        SetterLaws.check(setter: Setter<String, String>.identity(), eqA: String.order)
    }
    
}
