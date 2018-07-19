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
let userGetter = userIso.asGetter()
let userSetter = Setter<User, Token>(modify: { f in { user in User(token: f(user.token)) } })
let lengthGetter = Getter<String, Int>(get: { str in str.count })
let upperGetter = Getter<String, String>(get: { str in str.uppercased() })

let stringPrism = Prism(getOrModify: { (str : String) in Either<String, String>.right(String(str.reversed())) },
                        reverseGet: { (reversed : String) in String(reversed.reversed()) })

enum SumType {
    static var eq : SumTypeEq {
        return SumTypeEq()
    }
    
    case a(String)
    case b(Int)
    
    var isA : Bool {
        switch self {
        case .a(_): return true
        default: return false
        }
    }
}

class SumTypeEq : Eq {
    typealias A = SumType
    
    func eqv(_ lhs: SumType, _ rhs: SumType) -> Bool {
        switch (lhs, rhs) {
        case let (.a(left), .a(right)): return left == right
        case let (.b(left), .b(right)): return left == right
        default: return false
        }
    }
}

extension SumType : Arbitrary {
    static var arbitrary: Gen<SumType> {
        return Gen.one(of: [String.arbitrary.map(SumType.a), Int.arbitrary.map(SumType.b)])
    }
}

let sumPrism = Prism<SumType, String>(getOrModify: { sum in
    switch sum {
    case let .a(str): return Either.right(str)
    default: return Either.left(sum)
    }
}, reverseGet: SumType.a)
