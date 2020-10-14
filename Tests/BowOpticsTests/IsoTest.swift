import XCTest
import SwiftCheck
import Bow
import BowOptics
import BowOpticsLaws
import BowLaws

class IsoTest: XCTestCase {
    
    func testIsoLaws() {
        IsoLaws.check(iso: Token.iso)
    }
    
    func testPrismLaws() {
        PrismLaws.check(prism: Token.iso.asPrism)
    }
    
    func testLensLaws() {
        LensLaws.check(lens: Token.iso.asLens)
    }
    
    func testAffineTraversalLaws() {
        AffineTraversalLaws.check(affineTraversal: Token.iso.asAffineTraversal)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: Token.iso.asSetter)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: Token.iso.asTraversal)
    }
    
    func testIsoAsFold() {
        property("Iso as Fold: size") <~ forAll { (token: Token) in
            return Token.iso.asFold.size(token) == 1
        }
        
        property("Iso as Fold: nonEmpty") <~ forAll { (token: Token) in
            return Token.iso.asFold.nonEmpty(token)
        }
        
        property("Iso as Fold: isEmpty") <~ forAll { (token: Token) in
            return !Token.iso.asFold.isEmpty(token)
        }
        
        property("Iso as Fold: getAll") <~ forAll { (token: Token) in
            return Token.iso.asFold.getAll(token) == ArrayK.pure(token.value)
        }
        
        property("Iso as Fold: combineAll") <~ forAll { (token: Token) in
            return Token.iso.asFold.combineAll(token) == token.value
        }
        
        property("Iso as Fold: fold") <~ forAll { (token: Token) in
            return Token.iso.asFold.fold(token) == token.value
        }
        
        property("Iso as Fold: headOption") <~ forAll { (token: Token) in
            return Token.iso.asFold.headOption(token) == Option.some(token.value)
        }
        
        property("Iso as Fold: lastOption") <~ forAll { (token: Token) in
            return Token.iso.asFold.lastOption(token) == Option.some(token.value)
        }
    }
    
    func testIsoAsGetter() {
        property("Iso as Getter: get") <~ forAll { (token: Token) in
            return Token.iso.asGetter.get(token) == Token.getter.get(token)
        }
        
        property("Iso as Getter: find") <~ forAll { (token: Token, predicate: ArrowOf<String, Bool>) in
            return Token.iso.asGetter.find(token, predicate.getArrow) == Token.getter.find(token, predicate.getArrow)
        }
        
        property("Iso as Getter: exists") <~ forAll { (token: Token, predicate: ArrowOf<String, Bool>) in
            return Token.iso.asGetter.find(token, predicate.getArrow) ==
                Token.getter.find(token, predicate.getArrow)
        }
    }
    
    func testIsoProperties() {
        property("Lifting a function should yield the same value as not yielding") <~ forAll { (token: Token, value: String) in
            return Token.iso.modify(token, constant(value)) == Token.iso.lift(constant(value))(token)
        }
        
        property("Lifting a function as a functior should yield the same value as not yielding") <~ forAll { (token: Token, value: String) in
            return Token.iso.modifyF(token, constant(Option.some(value))) ==
                Token.iso.liftF(constant(Option.some(value)))(token)
        }
        
        property("Creating a first pair with a type should result in the target to value") <~ forAll { (token: Token, value: Int) in
            let first : Iso<(Token, Int), (String, Int)> = Token.iso.first()
            return first.get((token, value)) == (Token.iso.get(token), value)
        }
        
        property("Creating a second pair with a type should result in the value to target") <~ forAll { (token: Token, value: Int) in
            let second : Iso<(Int, Token), (Int, String)> = Token.iso.second()
            return second.get((value, token)) == (value, Token.iso.get(token))
        }
        
        property("Creating a left with a type should result in the sum of value and target") <~ forAll { (token: Token, value: Int) in
            let left : Iso<Either<Token, Int>, Either<String, Int>> = Token.iso.left()
            return left.get(Either.left(token)) == Either.left(Token.iso.get(token)) &&
                left.get(Either.right(value)) == Either.right(value)
        }
        
        property("Creating a right with a type should result in the sum of target and value") <~ forAll { (token: Token, value: Int) in
            let right : Iso<Either<Int, Token>, Either<Int, String>> = Token.iso.right()
            return right.get(Either.right(token)) == Either.right(Token.iso.get(token)) &&
                right.get(Either.left(value)) == Either.left(value)
        }
        
        property("Finding a target using a predicate within an Iso should be wrapped in the correct option result") <~ forAll { (predicate: Bool) in
            return Token.iso.find(Token(value: "Any value"), constant(predicate)).fold(constant(false), constant(true)) == predicate
        }
        
        property("Checking existence predicate over the target should result in the same result as predicate") <~ forAll { (predicate: Bool) in
            return Token.iso.exists(Token(value: "Any value"), constant(predicate)) == predicate
        }
        
        property("Pairing two disjoint isos together") <~ forAll { (tokenValue: String) in
            let token = Token(value: tokenValue)
            let user = User(token: token)
            let joinedIso = Token.iso.split(User.iso)
            return joinedIso.get((token, user)) == (tokenValue, token)
        }
        
        property("Composing isos should result in an iso of the first iso's value to the second's target") <~ forAll { (tokenValue: String) in
            let composedIso = User.iso + Token.iso
            let token = Token(value: tokenValue)
            let user = User(token: token)
            return composedIso.get(user) == tokenValue
        }
        
        property("Reverse isomorphism") <~ forAll { (token: Token) in
            return Token.iso.reverse().reverse().get(token) == Token.iso.get(token)
        }
    }
    
    func testIsoComposition() {
        property("Iso + Iso::identity") <~ forAll { (token: Token) in
            return (Token.iso + Iso<String, String>.identity).get(token) == Token.iso.get(token)
        }
        
        property("Iso + Lens::identity") <~ forAll { (token: Token) in
            return (Token.iso + Lens<String, String>.identity).get(token) == Token.iso.get(token)
        }
        
        property("Iso + Prism::identity") <~ forAll { (token: Token) in
            return (Token.iso + Prism<String, String>.identity).getOption(token).getOrElse("") == Token.iso.get(token)
        }
        
        property("Iso + Getter::identity") <~ forAll { (token: Token) in
            return (Token.iso + Getter<String, String>.identity).get(token) == Token.iso.get(token)
        }
        
        property("Iso + Setter::identity") <~ forAll { (token: Token) in
            return (Token.iso + Setter<String, String>.identity).set(token, "Any") == Token.iso.set("Any")
        }
        
        property("Iso + AffineTraversal::identity") <~ forAll { (token: Token) in
            return (Token.iso + AffineTraversal<String, String>.identity).getOption(token).getOrElse("") == Token.iso.get(token)
        }
        
        property("Iso + Fold::identity") <~ forAll { (token: Token) in
            return (Token.iso + Fold<String, String>.identity).getAll(token).asArray == [Token.iso.get(token)]
        }
        
        property("Iso + Traversal::identity") <~ forAll { (token: Token) in
            return (Token.iso + Traversal<String, String>.identity).getAll(token).asArray == [Token.iso.get(token)]
        }
    }
}
