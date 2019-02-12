import Foundation

extension String: Semigroup {
    public func combine(_ other: String) -> String {
        return self + other
    }
}

extension String: Monoid {
    public static func empty() -> String {
        return ""
    }
}
