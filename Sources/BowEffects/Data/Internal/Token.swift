import Foundation

internal class Token {
    private let id: Double = Date().timeIntervalSince1970
}

extension Token: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Token: Equatable {}

func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs === rhs
}

extension Token: CustomStringConvertible {
    var description: String {
        return "Token(\(hashValue))"
    }
}
