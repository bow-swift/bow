import XCTest
import SwiftCheck
import Bow
import BowOptics
import BowOpticsLaws
import BowLaws

class SetterTest: XCTestCase {
    
    func testSetterLaws() {
        SetterLaws.check(setter: tokenSetter)
        SetterLaws.check(setter: Setter<String, String>.identity)
    }
    
    func testSetterProperties() {
        property("Joining two Setters together with same target should yield same result") <~ forAll { (value: String) in
            let userTokenStringSetter = userSetter + tokenSetter
            let joinedSetter = tokenSetter.choice(userTokenStringSetter)
            let oldValue = "Old value"
            let token = Token(value: oldValue)
            let user = User(token: token)
            return joinedSetter.set(Either.left(token), value).swap().getOrElse(Token(value: "Wrong value")).value == joinedSetter.set(Either.right(user), value).getOrElse(User(token: Token(value: "Wrong value"))).token.value
        }
        
        property("Lifting a function should yield the same result as direct modify") <~ forAll { (token: Token, value: String) in
            return tokenSetter.modify(token, constant(value)) == tokenSetter.lift(constant(value))(token)
        }
    }
    
    func testSetterComposition() {
        property("Setter + Setter::identity") <~ forAll { (token: Token, value: String) in
            return (tokenSetter + Setter<String, String>.identity).set(token, value) == tokenSetter.set(token, value)
        }
        
        property("Setter + Iso::identity") <~ forAll { (token: Token, value: String) in
            return (tokenSetter + Iso<String, String>.identity).set(token, value) == tokenSetter.set(token, value)
        }
        
        property("Setter + Lens::identity") <~ forAll { (token: Token, value: String) in
            return (tokenSetter + Lens<String, String>.identity).set(token, value) == tokenSetter.set(token, value)
        }
        
        property("Setter + Prism::identity") <~ forAll { (token: Token, value: String) in
            return (tokenSetter + Prism<String, String>.identity).set(token, value) == tokenSetter.set(token, value)
        }
        
        property("Setter + Optional::identity") <~ forAll { (token: Token, value: String) in
            return (tokenSetter + BowOptics.Optional<String, String>.identity).set(token, value) == tokenSetter.set(token, value)
        }
        
        property("Setter + Traversal::identity") <~ forAll { (token: Token, value: String) in
            return (tokenSetter + Traversal<String, String>.identity).set(token, value) == tokenSetter.set(token, value)
        }
    }
}
