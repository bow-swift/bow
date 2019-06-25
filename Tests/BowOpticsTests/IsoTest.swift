import XCTest
import SwiftCheck
import Bow
import BowOptics

class IsoTest: XCTestCase {
    
    func testIsoLaws() {
        IsoLaws.check(iso: tokenIso)
    }
    
    func testPrismLaws() {
        PrismLaws.check(prism: tokenIso.asPrism)
    }
    
    func testLensLaws() {
        LensLaws.check(lens: tokenIso.asLens)
    }
    
    func testOptionalLaws() {
        OptionalLaws.check(optional: tokenIso.asOptional)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: tokenIso.asSetter)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: tokenIso.asTraversal)
    }
    
    func testIsoAsFold() {
        property("Iso as Fold: size") <- forAll { (token: Token) in
            return tokenIso.asFold.size(token) == 1
        }
        
        property("Iso as Fold: nonEmpty") <- forAll { (token: Token) in
            return tokenIso.asFold.nonEmpty(token)
        }
        
        property("Iso as Fold: isEmpty") <- forAll { (token: Token) in
            return !tokenIso.asFold.isEmpty(token)
        }
        
        property("Iso as Fold: getAll") <- forAll { (token: Token) in
            return tokenIso.asFold.getAll(token) == ArrayK.pure(token.value)
        }
        
        property("Iso as Fold: combineAll") <- forAll { (token: Token) in
            return tokenIso.asFold.combineAll(token) == token.value
        }
        
        property("Iso as Fold: fold") <- forAll { (token: Token) in
            return tokenIso.asFold.fold(token) == token.value
        }
        
        property("Iso as Fold: headOption") <- forAll { (token: Token) in
            return tokenIso.asFold.headOption(token) == Option.some(token.value)
        }
        
        property("Iso as Fold: lastOption") <- forAll { (token: Token) in
            return tokenIso.asFold.lastOption(token) == Option.some(token.value)
        }
    }
    
    func testIsoAsGetter() {
        property("Iso as Getter: get") <- forAll { (token: Token) in
            return tokenIso.asGetter.get(token) == tokenGetter.get(token)
        }
        
        property("Iso as Getter: find") <- forAll { (token: Token, predicate: ArrowOf<String, Bool>) in
            return tokenIso.asGetter.find(token, predicate.getArrow) == tokenGetter.find(token, predicate.getArrow)
        }
        
        property("Iso as Getter: exists") <- forAll { (token: Token, predicate: ArrowOf<String, Bool>) in
            return tokenIso.asGetter.find(token, predicate.getArrow) ==
                tokenGetter.find(token, predicate.getArrow)
        }
    }
    
    func testIsoProperties() {
        property("Lifting a function should yield the same value as not yielding") <- forAll { (token: Token, value: String) in
            return tokenIso.modify(token, constant(value)) == tokenIso.lift(constant(value))(token)
        }
        
        property("Lifting a function as a functior should yield the same value as not yielding") <- forAll { (token: Token, value: String) in
            return tokenIso.modifyF(token, constant(Option.some(value))) ==
                tokenIso.liftF(constant(Option.some(value)))(token)
        }
        
        property("Creating a first pair with a type should result in the target to value") <- forAll { (token: Token, value: Int) in
            let first : Iso<(Token, Int), (String, Int)> = tokenIso.first()
            return first.get((token, value)) == (tokenIso.get(token), value)
        }
        
        property("Creating a second pair with a type should result in the value to target") <- forAll { (token: Token, value: Int) in
            let second : Iso<(Int, Token), (Int, String)> = tokenIso.second()
            return second.get((value, token)) == (value, tokenIso.get(token))
        }
        
        property("Creating a left with a type should result in the sum of value and target") <- forAll { (token: Token, value: Int) in
            let left : Iso<Either<Token, Int>, Either<String, Int>> = tokenIso.left()
            return left.get(Either.left(token)) == Either.left(tokenIso.get(token)) &&
                left.get(Either.right(value)) == Either.right(value)
        }
        
        property("Creating a right with a type should result in the sum of target and value") <- forAll { (token: Token, value: Int) in
            let right : Iso<Either<Int, Token>, Either<Int, String>> = tokenIso.right()
            return right.get(Either.right(token)) == Either.right(tokenIso.get(token)) &&
                right.get(Either.left(value)) == Either.left(value)
        }
        
        property("Finding a target using a predicate within an Iso should be wrapped in the correct option result") <- forAll { (predicate: Bool) in
            return tokenIso.find(Token(value: "Any value"), constant(predicate)).fold(constant(false), constant(true)) == predicate
        }
        
        property("Checking existence predicate over the target should result in the same result as predicate") <- forAll { (predicate: Bool) in
            return tokenIso.exists(Token(value: "Any value"), constant(predicate)) == predicate
        }
        
        property("Pairing two disjoint isos together") <- forAll { (tokenValue: String) in
            let token = Token(value: tokenValue)
            let user = User(token: token)
            let joinedIso = tokenIso.split(userIso)
            return joinedIso.get((token, user)) == (tokenValue, token)
        }
        
        property("Composing isos should result in an iso of the first iso's value to the second's target") <- forAll { (tokenValue: String) in
            let composedIso = userIso + tokenIso
            let token = Token(value: tokenValue)
            let user = User(token: token)
            return composedIso.get(user) == tokenValue
        }
        
        property("Reverse isomorphism") <- forAll { (token: Token) in
            return tokenIso.reverse().reverse().get(token) == tokenIso.get(token)
        }
    }
    
    func testIsoComposition() {
        property("Iso + Iso::identity") <- forAll { (token: Token) in
            return (tokenIso + Iso<String, String>.identity).get(token) == tokenIso.get(token)
        }
        
        property("Iso + Lens::identity") <- forAll { (token: Token) in
            return (tokenIso + Lens<String, String>.identity).get(token) == tokenIso.get(token)
        }
        
        property("Iso + Prism::identity") <- forAll { (token: Token) in
            return (tokenIso + Prism<String, String>.identity).getOption(token).getOrElse("") == tokenIso.get(token)
        }
        
        property("Iso + Getter::identity") <- forAll { (token: Token) in
            return (tokenIso + Getter<String, String>.identity).get(token) == tokenIso.get(token)
        }
        
        property("Iso + Setter::identity") <- forAll { (token: Token) in
            return (tokenIso + Setter<String, String>.identity).set(token, "Any") == tokenIso.set("Any")
        }
        
        property("Iso + Optional::identity") <- forAll { (token: Token) in
            return (tokenIso + BowOptics.Optional<String, String>.identity).getOption(token).getOrElse("") == tokenIso.get(token)
        }
        
        property("Iso + Fold::identity") <- forAll { (token: Token) in
            return (tokenIso + Fold<String, String>.identity).getAll(token).asArray == [tokenIso.get(token)]
        }
        
        property("Iso + Traversal::identity") <- forAll { (token: Token) in
            return (tokenIso + Traversal<String, String>.identity).getAll(token).asArray == [tokenIso.get(token)]
        }
    }
}
