import Foundation

public extension String {
    /// Instance of `Semigroup` for `String`, using concatenation as combination method.
    ///
    /// Use `String.concatSemigroup` to obtain an instance of this type.
    public class ConcatSemigroupInstance : Semigroup {
        public typealias A = String
        
        public func combine(_ a : String, _ b : String) -> String {
            return a + b
        }
    }

    /// Instance of `Monoid` for `String`, using concatenation as combination method.
    ///
    /// Use `String.concatMonoid` to obtain an instance of this type.
    public class ConcatMonoidInstance : ConcatSemigroupInstance, Monoid {
        public var empty : String {
            return ""
        }
    }

    /// Instance of `Eq` for `String`.
    ///
    /// Use `String.eq` to obtain an instance of this type.
    public class EqInstance : Eq {
        public typealias A = String
        
        public func eqv(_ a: String, _ b: String) -> Bool {
            return a == b
        }
    }

    /// Instance of `Order` for `String`.
    ///
    /// Use `String.order` to obtain an instance of this type.
    public class OrderInstance : EqInstance, Order {
        public func compare(_ a: String, _ b: String) -> Int {
            switch a.compare(b) {
            case .orderedAscending: return -1
            case .orderedDescending: return 1
            case .orderedSame: return 0
            }
        }
    }

    /// Provides an instance of `Semigroup` for `String`, using concatenation as combination method.
    public static var concatSemigroup : ConcatSemigroupInstance {
        return ConcatSemigroupInstance()
    }
    
    /// Provides an instance of `Monoid` for `String`, using concatenation as combination method.
    public static var concatMonoid : ConcatMonoidInstance {
        return ConcatMonoidInstance()
    }
    
    /// Provides an instance of `Eq` for `String`.
    public static var eq : EqInstance {
        return EqInstance()
    }
    
    /// Provides an instance of `Order` for `String`.
    public static var order : OrderInstance {
        return OrderInstance()
    }
}
