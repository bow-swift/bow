import Foundation

public protocol Order : Eq {
    func compare(_ a : A, _ b : A) -> Int
}

public extension Order {
    public func eqv(_ a: A, _ b: A) -> Bool {
        return compare(a, b) == 0
    }
    
    public func lt(_ a: A, _ b : A) -> Bool {
        return compare(a, b) < 0
    }
    
    public func lte(_ a : A, _ b : A) -> Bool {
        return compare(a, b) <= 0
    }
    
    public func gt(_ a : A, _ b : A) -> Bool {
        return compare(a, b) > 0
    }
    
    public func gte(_ a : A, _ b : A) -> Bool {
        return compare(a, b) >= 0
    }
    
    public func max(_ a : A, _ b : A) -> A {
        return gt(a, b) ? a : b
    }
    
    public func min(_ a : A, _ b : A) -> A {
        return lt(a, b) ? a : b
    }
    
    public func sort(_ a : A, _ b : A) -> (A, A) {
        return gte(a, b) ? (a, b) : (b, a)
    }
}
