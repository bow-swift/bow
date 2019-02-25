import Foundation

public protocol Monoid: Semigroup {
    static func empty() -> Self
}
