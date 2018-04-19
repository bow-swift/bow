import Foundation

public protocol Monoid : Semigroup {
    var empty : A { get }
}
