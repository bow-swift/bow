import Foundation

public protocol Semigroup {
    func combine(_ other: Self) -> Self
}

public extension Semigroup {
    public static func combine(_ a: Self, _ b: Self) -> Self {
        return a.combine(b)
    }

    public static func combineAll(_ elems: Self...) -> Self {
        return combineAll(elems)
    }
    
    public static func combineAll(_ elems: [Self]) -> Self {
        return elems[1 ..< elems.count].reduce(elems[0], { partial, next in partial.combine(next) })
    }
}
