import Foundation

public class StringConcatSemigroup : Semigroup {
    public typealias A = String
    
    public func combine(_ a : String, _ b : String) -> String {
        return a + b
    }
}

public class StringConcatMonoid : StringConcatSemigroup, Monoid {
    public var empty : String {
        return ""
    }
}

public class StringEq : Eq {
    public typealias A = String
    
    public func eqv(_ a: String, _ b: String) -> Bool {
        return a == b
    }
}

public class StringOrder : StringEq, Order {
    public func compare(_ a: String, _ b: String) -> Int {
        switch a.compare(b) {
        case .orderedAscending: return -1
        case .orderedDescending: return 1
        case .orderedSame: return 0
        }
    }
}

public extension String {
    public static var concatSemigroup : StringConcatSemigroup {
        return StringConcatSemigroup()
    }
    
    public static var concatMonoid : StringConcatMonoid {
        return StringConcatMonoid()
    }
    
    public static var eq : StringEq {
        return StringEq()
    }
    
    public static var order : StringOrder {
        return StringOrder()
    }
}
