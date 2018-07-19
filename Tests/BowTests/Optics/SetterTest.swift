import XCTest
import SwiftCheck
@testable import Bow

class SetterTest: XCTestCase {
    
    func testSetterLaws() {
        SetterLaws.check(setter: tokenSetter, eqA: Token.eq, generatorA: Token.arbitrary)
        SetterLaws.check(setter: Setter<String, String>.identity(), eqA: String.order, generatorA: String.arbitrary)
    }
    
    func testSetterProperties() {
        property("Joining two Setters together with same target should yield same result") <- forAll { (value : String) in
            let userTokenStringSetter = userSetter + tokenSetter
            let joinedSetter = tokenSetter.choice(userTokenStringSetter)
            let oldValue = "Old value"
            let token = Token(value: oldValue)
            let user = User(token: token)
            return joinedSetter.set(Either.left(token), value).swap().getOrElse(Token(value: "Wrong value")).value == joinedSetter.set(Either.right(user), value).getOrElse(User(token: Token(value: "Wrong value"))).token.value
        }
        
        property("Lifting a function should yield the same result as direct modify") <- forAll { (token : Token, value : String) in
            return tokenSetter.modify(token, constant(value)) == tokenSetter.lift(constant(value))(token)
        }
    }
}
