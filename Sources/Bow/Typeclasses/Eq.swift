import Foundation

public protocol Eq : Typeclass {
    associatedtype A
    
    func eqv(_ a : A, _ b : A) -> Bool
}

public extension Eq {
    public func neqv(_ a : A, _ b : A) -> Bool {
        return !eqv(a, b)
    }
}
