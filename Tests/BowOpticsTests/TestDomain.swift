import Foundation
import SwiftCheck
import Bow
import BowOptics

// MARK: - Token <testing>
struct Token {
    let value : String
    
    // MARK: helpers
    static let iso = Iso(get: { (token : Token) in token.value }, reverseGet: Token.init )
    static let lens = Lens(get: { (token : Token) in token.value }, set: { (_ : Token, newValue : String) in Token(value: newValue) })
    static let setter = Setter(modify: { s in { token in Token(value: s(token.value)) } })
    static let getter = Getter(get: { (t : Token) in t.value })
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


// MARK: - User <testing>
struct User {
    let token : Token
    
    // MARK: helpers
    static let iso = Iso<User, Token>(get: { user in user.token }, reverseGet: User.init)
    static let lens = Lens<User, Token>(get: { user in user.token }, set: { user, newToken in User(token: newToken) })
    static let getter = User.iso.asGetter
    static let setter = Setter<User, Token>(modify: { f in { user in User(token: f(user.token)) } })
}

extension User : Arbitrary {
    static var arbitrary : Gen<User> {
        return Token.arbitrary.map(User.init)
    }
}


// MARK: - SumType <testing>
enum SumType {
    case a(String)
    case b(Int)

    var isA : Bool {
        switch self {
        case .a(_): return true
        default: return false
        }
    }
    
    // MARK: helpers
    static let prism = Prism<SumType, String>(getOrModify: { sum in
        switch sum {
        case let .a(str): return Either.right(str)
        default: return Either.left(sum)
        }
    }, reverseGet: SumType.a)

    static let optionalHead = AffineTraversal<Array<Int>, Int>(
        set: { array, value in [value] + ((array.count > 1) ? Array(array.dropFirst()) : [])},
        getOrModify: { array in Option.fromOptional(array.first).fold(constant(Either.left(array)), Either.right) })

    static let defaultHead = AffineTraversal<Int, Int>(set: { a, _ in a }, getOrModify: Either.right)
}

extension SumType : Equatable {}

func ==(lhs : SumType, rhs : SumType) -> Bool {
    switch (lhs, rhs) {
    case let (.a(left), .a(right)): return left == right
    case let (.b(left), .b(right)): return left == right
    default: return false
    }
}

extension SumType : Arbitrary {
    static var arbitrary: Gen<SumType> {
        return Gen.one(of: [String.arbitrary.map(SumType.a), Int.arbitrary.map(SumType.b)])
    }
}


// MARK: - String <testing>
enum StringStyle {
    static let lengthGetter = Getter<String, Int>(get: { str in str.count })
    static let upperGetter = Getter<String, String>(get: { str in str.uppercased() })
    static let prism = Prism(getOrModify: { (str : String) in Either<String, String>.right(String(str.reversed())) },
                              reverseGet: { (reversed : String) in String(reversed.reversed()) })
}


// MARK: - Prism models <testing>
enum Authentication: AutoPrism {
    case unathorized(String)
    case authorized(Int, String)
    case requested(Int, info: String)
    case unkown
}

enum ChildAction {
    case changeColor
}
enum ParentAction: AutoPrism {
    case child(child: ChildAction)
}
