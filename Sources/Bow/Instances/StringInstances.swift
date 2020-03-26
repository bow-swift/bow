import Foundation

// MARK: Instance of Semigroup for String, using concatenation as combination method
extension String: Semigroup {
    public func combine(_ other: String) -> String {
        self + other
    }
}

// MARK: Instance of Monoid for String, using empty string as empty element
extension String: Monoid {
    public static func empty() -> String {
        ""
    }
}
