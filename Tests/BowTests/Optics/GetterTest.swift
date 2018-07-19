import XCTest
import SwiftCheck
@testable import Bow

class GetterTest : XCTestCase {
    func testGetterAsFold() {
        property("Getter as Fold: size") <- forAll { (token : Token) in
            return tokenGetter.asFold().size(token) == 1
        }
        
        property("Getter as Fold: nonEmpty") <- forAll { (token : Token) in
            return tokenGetter.asFold().nonEmpty(token)
        }
        
        property("Getter as Fold: isEmpty") <- forAll { (token : Token) in
            return !tokenGetter.asFold().isEmpty(token)
        }
        
        property("Getter as Fold: getAll") <- forAll { (token : Token) in
            return ListK.eq(String.order).eqv(tokenGetter.asFold().getAll(token),
                                              ListK.pure(token.value))
        }
        
        property("Getter as Fold: combineAll") <- forAll { (token : Token) in
            return tokenGetter.asFold().combineAll(String.concatMonoid, token) == token.value
        }
        
        property("Getter as Fold: fold") <- forAll { (token : Token) in
            return tokenGetter.asFold().fold(String.concatMonoid, token) == token.value
        }
        
        property("Getter as Fold: headMaybe") <- forAll { (token : Token) in
            return Maybe.eq(String.order).eqv(tokenGetter.asFold().headMaybe(token),
                                              Maybe.some(token.value))
        }
        
        property("Getter as Fold: lastMaybe") <- forAll { (token : Token) in
            return Maybe.eq(String.order).eqv(tokenGetter.asFold().lastMaybe(token),
                                              Maybe.some(token.value))
        }
    }
    
    func testGetterProperties() {
        property("Getting the target should yield the exact value") <- forAll { (value : String) in
            return tokenGetter.get(Token(value: value)) == value
        }
        
        property("Finding a target using a predicate within a Getter should be wrapped in the correct Maybe result") <- forAll { (token : Token, predicate : Bool) in
            return tokenGetter.find(token, constant(predicate)).fold(constant(false), constant(true)) == predicate
        }
        
        property("Checking the existence of a target should result in the same result as the predicate") <- forAll { (token : Token, predicate : Bool) in
            return tokenGetter.exists(token, constant(predicate)) == predicate
        }
        
        property("Zipping two Getters should yield a tuple of the targets") <- forAll { (value : String) in
            let zippedGetter = lengthGetter.zip(upperGetter)
            return zippedGetter.get(value) == (value.count, value.uppercased())
        }
        
        property("Joining two Getters together with the same target should yield the same result") <- forAll { (value : String) in
            let userTokenStringGetter = userGetter + tokenGetter
            let joinedGetter = tokenGetter.choice(userTokenStringGetter)
            let token = Token(value: value)
            let user = User(token: token)
            return joinedGetter.get(Either.left(token)) == joinedGetter.get(Either.right(user))
        }
        
        property("Pairing two disjoint Getters should yield a pair of their results") <- forAll { (token : Token, user : User) in
            let splitGetter = tokenGetter.split(userGetter)
            return splitGetter.get((token, user)) == (token.value, user.token)
        }
        
        property("Creating a first pair with a type should result in the target to value") <- forAll { (token : Token, value : Int) in
            let first : Getter<(Token, Int), (String, Int)> = tokenGetter.first()
            return first.get((token, value)) == (token.value, value)
        }
        
        property("Creating a second pair with a type should result in the value to target") <- forAll { (token : Token, value : Int) in
            let second : Getter<(Int, Token), (Int, String)> = tokenGetter.second()
            return second.get((value, token)) == (value, token.value)
        }
        
        property("Creating a left with a type should result in the sum of value and target") <- forAll { (token : Token, value : Int) in
            let left : Getter<Either<Token, Int>, Either<String, Int>> = tokenGetter.left()
            let eq = Either.eq(String.order, Int.order)
            return eq.eqv(left.get(Either.left(token)),
                          Either.left(tokenIso.get(token))) &&
                eq.eqv(left.get(Either.right(value)),
                       Either.right(value))
        }
        
        property("Creating a right with a type should result in the sum of target and value") <- forAll { (token : Token, value : Int) in
            let right : Getter<Either<Int, Token>, Either<Int, String>> = tokenGetter.right()
            let eq = Either.eq(Int.order, String.order)
            return eq.eqv(right.get(Either.right(token)),
                          Either.right(tokenIso.get(token))) &&
                eq.eqv(right.get(Either.left(value)),
                       Either.left(value))
        }
    }
}
