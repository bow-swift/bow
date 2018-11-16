import XCTest
import SwiftCheck
@testable import Bow
@testable import BowOptics

class LensTest: XCTestCase {
    
    func testLensLaws() {
        LensLaws.check(lens: tokenLens, eqA: Token.eq, eqB: String.order)
    }
    
    func testOptionalLaws() {
        OptionalLaws.check(optional: tokenLens.asOptional(), eqA: Token.eq, eqB: String.order)
    }
    
    func testSetterLaws() {
        SetterLaws.check(setter: tokenLens.asSetter(), eqA: Token.eq, generatorA: Token.arbitrary)
    }
    
    func testTraversalLaws() {
        TraversalLaws.check(traversal: tokenLens.asTraversal(), eqA: Token.eq, eqB: String.order, generatorA: Token.arbitrary)
    }
    
    func testLensAsFold() {
        property("Lens as Fold: size") <- forAll { (token : Token) in
            return tokenLens.asFold().size(token) == 1
        }
        
        property("Lens as Fold: nonEmpty") <- forAll { (token : Token) in
            return tokenLens.asFold().nonEmpty(token)
        }
        
        property("Lens as Fold: isEmpty") <- forAll { (token : Token) in
            return !tokenLens.asFold().isEmpty(token)
        }
        
        property("Lens as Fold: getAll") <- forAll { (token : Token) in
            return ListK.eq(String.order).eqv(tokenLens.asFold().getAll(token),
                                              ListK.pure(token.value))
        }
        
        property("Lens as Fold: combineAll") <- forAll { (token : Token) in
            return tokenLens.asFold().combineAll(String.concatMonoid, token) == token.value
        }
        
        property("Lens as Fold: headOption") <- forAll { (token : Token) in
            return Option.eq(String.order).eqv(tokenLens.asFold().headOption(token),
                                              Option.some(token.value))
        }
        
        property("Lens as Fold: lastOption") <- forAll { (token : Token) in
            return Option.eq(String.order).eqv(tokenLens.asFold().lastOption(token),
                                              Option.some(token.value))
        }
    }
    
    func testLensAsGetter() {
        property("Lens as Getter: get") <- forAll { (token : Token) in
            return tokenLens.asGetter().get(token) == tokenGetter.get(token)
        }
        
        property("Lens as Getter: find") <- forAll { (token : Token, predicate : ArrowOf<String, Bool>) in
            return Option.eq(String.order).eqv(tokenLens.asGetter().find(token, predicate.getArrow),
                                              tokenGetter.find(token, predicate.getArrow))
        }
        
        property("Lens as Getter: exists") <- forAll { (token : Token, predicate : ArrowOf<String, Bool>) in
            return tokenLens.asGetter().exists(token, predicate.getArrow) ==
                tokenGetter.exists(token, predicate.getArrow)
        }
    }
    
    func testLensProperties() {
        property("Lifting a function should yield the same result as not yielding") <- forAll { (token : Token, value : String) in
            return Token.eq.eqv(tokenLens.set(token, value),
                                tokenLens.lift(constant(value))(token))
        }
        
        property("Lifting a function as a functor should yield the same result as not yielding") <- forAll { (token : Token, value : String) in
            return Option.eq(Token.eq).eqv(tokenLens.modifyF(Option<String>.functor(), token, constant(Option.some(value))),
                                          tokenLens.liftF(Option<String>.functor(), constant(Option.some(value)))(token))
        }
        
        property("Finding a target using a predicate within a Lens should be wrapped in the correct option result") <- forAll { (predicate : Bool) in
            return tokenLens.find(Token(value: "Any value"), constant(predicate)).fold(constant(false), constant(true)) == predicate
        }
        
        property("Checking existence predicate over the target should result in same result as predicate") <- forAll { (predicate : Bool) in
            return tokenLens.exists(Token(value: "Any value"), constant(predicate)) == predicate
        }
        
        property("Joining two lenses with the same target should yield same result") <- forAll { (tokenValue : String) in
            let token = Token(value: tokenValue)
            let user = User(token: token)
            let userTokenStringLens = userLens + tokenLens
            let joinedLens = tokenLens.choice(userTokenStringLens)
            return joinedLens.get(Either.left(token)) == joinedLens.get(Either.right(user))
        }
        
        property("Pairing two disjoint lenses should yield a pair of their results") <- forAll { (token : Token, user : User) in
            let split = userLens.split(tokenLens)
            return split.get((user, token)) == (user.token, token.value)
        }
        
        property("Creating a first pair with a type should result in the target to value") <- forAll { (token : Token, value : Int) in
            let first : Lens<(Token, Int), (String, Int)> = tokenLens.first()
            return first.get((token, value)) == (token.value, value)
        }
        
        property("Creating a second pair with a type should result in the value to target") <- forAll { (token : Token, value : Int) in
            let second : Lens<(Int, Token), (Int, String)> = tokenLens.second()
            return second.get((value, token)) == (value, token.value)
        }
    }
    
    func testLensComposition() {
        property("Lens + Lens::identity") <- forAll { (token : Token) in
            return (tokenLens + Lens<String, String>.identity()).get(token) == tokenLens.get(token)
        }
        
        property("Lens + Iso::identity") <- forAll { (token : Token) in
            return (tokenLens + Iso<String, String>.identity()).get(token) == tokenLens.get(token)
        }
        
        property("Lens + Getter::identity") <- forAll { (token : Token) in
            return (tokenLens + Getter<String, String>.identity()).get(token) == tokenLens.get(token)
        }
        
        property("Lens + Prism::identity") <- forAll { (token : Token) in
            return (tokenLens + Prism<String, String>.identity()).getOption(token).getOrElse("") == tokenLens.get(token)
        }
        
        property("Lens + Optional::identity") <- forAll { (token : Token) in
            return (tokenLens + BowOptics.Optional<String, String>.identity()).getOption(token).getOrElse("") == tokenLens.get(token)
        }
        
        property("Lens + Setter::identity") <- forAll { (token : Token, value : String) in
            return (tokenLens + Setter<String, String>.identity()).set(token, value) == tokenLens.set(token, value)
        }
        
        property("Lens + Fold::identity") <- forAll { (token : Token) in
            return (tokenLens + Fold<String, String>.identity()).getAll(token).asArray == [tokenLens.get(token)]
        }
        
        property("Lens + Traversal::identity") <- forAll { (token : Token) in
            return (tokenLens + Traversal<String, String>.identity()).getAll(token).asArray == [tokenLens.get(token)]
        }
    }
}
