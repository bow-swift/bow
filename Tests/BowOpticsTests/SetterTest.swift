import XCTest
import SwiftCheck
import Bow
import BowOptics
import BowOpticsLaws
import BowLaws

class SetterTest: XCTestCase {
    
    func testSetterLaws() {
        SetterLaws.check(setter: Token.setter)
        SetterLaws.check(setter: Setter<String, String>.identity)
    }
    
    func testSetterProperties() {
        property("Joining two Setters together with same target should yield same result") <~ forAll { (value: String) in
            let userTokenStringSetter = User.setter + Token.setter
            let joinedSetter = Token.setter.choice(userTokenStringSetter)
            let oldValue = "Old value"
            let token = Token(value: oldValue)
            let user = User(token: token)
            return joinedSetter.set(Either.left(token), value).swap().getOrElse(Token(value: "Wrong value")).value == joinedSetter.set(Either.right(user), value).getOrElse(User(token: Token(value: "Wrong value"))).token.value
        }
        
        property("Lifting a function should yield the same result as direct modify") <~ forAll { (token: Token, value: String) in
            return Token.setter.modify(token, constant(value)) == Token.setter.lift(constant(value))(token)
        }
    }
    
    func testSetterComposition() {
        property("Setter + Setter::identity") <~ forAll { (token: Token, value: String) in
            return (Token.setter + Setter<String, String>.identity).set(token, value) == Token.setter.set(token, value)
        }
        
        property("Setter + Iso::identity") <~ forAll { (token: Token, value: String) in
            return (Token.setter + Iso<String, String>.identity).set(token, value) == Token.setter.set(token, value)
        }
        
        property("Setter + Lens::identity") <~ forAll { (token: Token, value: String) in
            return (Token.setter + Lens<String, String>.identity).set(token, value) == Token.setter.set(token, value)
        }
        
        property("Setter + Prism::identity") <~ forAll { (token: Token, value: String) in
            return (Token.setter + Prism<String, String>.identity).set(token, value) == Token.setter.set(token, value)
        }
        
        property("Setter + AffineTraversal::identity") <~ forAll { (token: Token, value: String) in
            return (Token.setter + AffineTraversal<String, String>.identity).set(token, value) == Token.setter.set(token, value)
        }
        
        property("Setter + Traversal::identity") <~ forAll { (token: Token, value: String) in
            return (Token.setter + Traversal<String, String>.identity).set(token, value) == Token.setter.set(token, value)
        }
    }
}
