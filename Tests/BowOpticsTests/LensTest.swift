import XCTest
import SwiftCheck
import Bow
import BowOptics
import BowOpticsLaws
import BowLaws

class LensTest: XCTestCase {
    
    func testLensLaws() {
        LensLaws.check(lens: Token.lens)
    }
    
    func testAffineTraversalLaws() {
        AffineTraversalLaws.check(affineTraversal: Token.lens.asAffineTraversal)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: Token.lens.asSetter)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: Token.lens.asTraversal)
    }
    
    func testLensAsFold() {
        property("Lens as Fold: size") <~ forAll { (token: Token) in
            return Token.lens.asFold.size(token) == 1
        }
        
        property("Lens as Fold: nonEmpty") <~ forAll { (token: Token) in
            return Token.lens.asFold.nonEmpty(token)
        }
        
        property("Lens as Fold: isEmpty") <~ forAll { (token: Token) in
            return !Token.lens.asFold.isEmpty(token)
        }
        
        property("Lens as Fold: getAll") <~ forAll { (token: Token) in
            return Token.lens.asFold.getAll(token) == ArrayK.pure(token.value)
        }
        
        property("Lens as Fold: combineAll") <~ forAll { (token: Token) in
            return Token.lens.asFold.combineAll(token) == token.value
        }
        
        property("Lens as Fold: headOption") <~ forAll { (token: Token) in
            return Token.lens.asFold.headOption(token) == Option.some(token.value)
        }
        
        property("Lens as Fold: lastOption") <~ forAll { (token: Token) in
            return Token.lens.asFold.lastOption(token) == Option.some(token.value)
        }
    }
    
    func testLensAsGetter() {
        property("Lens as Getter: get") <~ forAll { (token: Token) in
            return Token.lens.asGetter.get(token) == Token.getter.get(token)
        }
        
        property("Lens as Getter: find") <~ forAll { (token: Token, predicate: ArrowOf<String, Bool>) in
            return Token.lens.asGetter.find(token, predicate.getArrow) ==
                Token.getter.find(token, predicate.getArrow)
        }
        
        property("Lens as Getter: exists") <~ forAll { (token: Token, predicate: ArrowOf<String, Bool>) in
            return Token.lens.asGetter.exists(token, predicate.getArrow) ==
                Token.getter.exists(token, predicate.getArrow)
        }
    }
    
    func testLensProperties() {
        property("Lifting a function should yield the same result as not yielding") <~ forAll { (token: Token, value: String) in
            return Token.lens.set(token, value) == Token.lens.lift(constant(value))(token)
        }
        
        property("Lifting a function as a functor should yield the same result as not yielding") <~ forAll { (token: Token, value: String) in
            return Token.lens.modifyF(token, constant(Option.some(value))) ==
                Token.lens.liftF(constant(Option.some(value)))(token)
        }
        
        property("Finding a target using a predicate within a Lens should be wrapped in the correct option result") <~ forAll { (predicate: Bool) in
            return Token.lens.find(Token(value: "Any value"), constant(predicate)).fold(constant(false), constant(true)) == predicate
        }
        
        property("Checking existence predicate over the target should result in same result as predicate") <~ forAll { (predicate: Bool) in
            return Token.lens.exists(Token(value: "Any value"), constant(predicate)) == predicate
        }
        
        property("Joining two lenses with the same target should yield same result") <~ forAll { (tokenValue: String) in
            let token = Token(value: tokenValue)
            let user = User(token: token)
            let userTokenStringLens = User.lens + Token.lens
            let joinedLens = Token.lens.choice(userTokenStringLens)
            return joinedLens.get(Either.left(token)) == joinedLens.get(Either.right(user))
        }
        
        property("Pairing two disjoint lenses should yield a pair of their results") <~ forAll { (token: Token, user: User) in
            let split = User.lens.split(Token.lens)
            return split.get((user, token)) == (user.token, token.value)
        }
        
        property("Creating a first pair with a type should result in the target to value") <~ forAll { (token: Token, value: Int) in
            let first: Lens<(Token, Int), (String, Int)> = Token.lens.first()
            return first.get((token, value)) == (token.value, value)
        }
        
        property("Creating a second pair with a type should result in the value to target") <~ forAll { (token: Token, value: Int) in
            let second: Lens<(Int, Token), (Int, String)> = Token.lens.second()
            return second.get((value, token)) == (value, token.value)
        }
    }
    
    func testLensComposition() {
        property("Lens + Lens::identity") <~ forAll { (token: Token) in
            return (Token.lens + Lens<String, String>.identity).get(token) == Token.lens.get(token)
        }
        
        property("Lens + Iso::identity") <~ forAll { (token: Token) in
            return (Token.lens + Iso<String, String>.identity).get(token) == Token.lens.get(token)
        }
        
        property("Lens + Getter::identity") <~ forAll { (token: Token) in
            return (Token.lens + Getter<String, String>.identity).get(token) == Token.lens.get(token)
        }
        
        property("Lens + Prism::identity") <~ forAll { (token: Token) in
            return (Token.lens + Prism<String, String>.identity).getOption(token).getOrElse("") == Token.lens.get(token)
        }
        
        property("Lens + AffineTraversal::identity") <~ forAll { (token: Token) in
            return (Token.lens + AffineTraversal<String, String>.identity).getOption(token).getOrElse("") == Token.lens.get(token)
        }
        
        property("Lens + Setter::identity") <~ forAll { (token: Token, value: String) in
            return (Token.lens + Setter<String, String>.identity).set(token, value) == Token.lens.set(token, value)
        }
        
        property("Lens + Fold::identity") <~ forAll { (token: Token) in
            return (Token.lens + Fold<String, String>.identity).getAll(token).asArray == [Token.lens.get(token)]
        }
        
        property("Lens + Traversal::identity") <~ forAll { (token: Token) in
            return (Token.lens + Traversal<String, String>.identity).getAll(token).asArray == [Token.lens.get(token)]
        }
    }
}
