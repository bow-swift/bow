import Foundation

/**
 Instance of `Semigroup` for `String`, using concatenation as combination method.
 */
public class StringConcatSemigroup : Semigroup {
    public typealias A = String
    
    public func combine(_ a : String, _ b : String) -> String {
        return a + b
    }
}

/**
 Instance of `Monoid` for `String`, using concatenation as combination method.
 */
public class StringConcatMonoid : StringConcatSemigroup, Monoid {
    public var empty : String {
        return ""
    }
}

/**
 Instance of `Eq` for `String`.
 */
public class StringEq : Eq {
    public typealias A = String
    
    public func eqv(_ a: String, _ b: String) -> Bool {
        return a == b
    }
}

/**
 Instance of `Order` for `String`.
 */
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
    /// Provides an instance of `Semigroup`.
    public static var concatSemigroup : StringConcatSemigroup {
        return StringConcatSemigroup()
    }
    
    /// Provides an instance of `Monoid`.
    public static var concatMonoid : StringConcatMonoid {
        return StringConcatMonoid()
    }
    
    /// Provides an instance of `Eq`.
    public static var eq : StringEq {
        return StringEq()
    }
    
    /// Provides an instance of `Order`.
    public static var order : StringOrder {
        return StringOrder()
    }
}
