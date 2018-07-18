import Foundation
import SwiftCheck
@testable import Bow

struct Token {
    static var eq : TokenEq {
        return TokenEq()
    }
    let value : String
}

extension Token : Equatable {}

func ==(lhs : Token, rhs : Token) -> Bool {
    return lhs.value == rhs.value
}

extension Token : Arbitrary {
    static var arbitrary: Gen<Token> {
        return String.arbitrary.map(Token.init)
    }
}

class TokenEq : Eq {
    typealias A = Token
    
    func eqv(_ a: Token, _ b: Token) -> Bool {
        return a.value == b.value
    }
}

let tokenIso = Iso(get: { (token : Token) in token.value }, reverseGet: Token.init )
let tokenLens = Lens(get: { (token : Token) in token.value }, set: { (_ : Token, newValue : String) in Token(value: newValue) })
let tokenSetter = Setter(modify: { s in { token in Token(value: s(token.value)) } })
let tokenGetter = Getter(get: { (t : Token) in t.value })

struct User {
    let token : Token
}

extension User : Arbitrary {
    static var arbitrary : Gen<User> {
        return Token.arbitrary.map(User.init)
    }
}

let userIso = Iso<User, Token>(get: { user in user.token }, reverseGet: User.init)
let userLens = Lens<User, Token>(get: { user in user.token }, set: { user, newToken in User(token: newToken) })

let stringPrism = Prism(getOrModify: { (str : String) in Either<String, String>.right(String(str.reversed())) },
                        reverseGet: { (reversed : String) in String(reversed.reversed()) })
