import Foundation

public extension Bool {
    /**
     Instance of `Semigroup` for `Bool`. Uses conjunction as combination of elements.
     */
    public class AndSemigroup : Semigroup {
        public typealias A = Bool
        
        public func combine(_ a: Bool, _ b: Bool) -> Bool {
            return a && b
        }
    }

    /**
     Instance of `Monoid` for `Bool`. Uses conjunction as combination of elements.
     */
    public class AndMonoid : AndSemigroup, Monoid {
        public var empty : Bool {
            return true
        }
    }

    /**
     Instance of `Semigroup` for `Bool`. Uses disjunction as combination of elements.
     */
    public class OrSemigroup : Semigroup {
        public typealias A = Bool
        
        public func combine(_ a: Bool, _ b: Bool) -> Bool {
            return a || b
        }
    }

    /**
     Instance of `Monoid` for `Bool`. Uses disjunction as combination of elements.
     */
    public class OrMonoid : OrSemigroup, Monoid {
        public var empty : Bool {
            return false
        }
    }

    /**
     Instance of `Eq` for `Bool`.
     */
    public class BoolEq : Eq {
        public typealias A = Bool
        
        public func eqv(_ a: Bool, _ b: Bool) -> Bool {
            return a == b
        }
    }

    /**
     Provides an instance of `Semigroup` for `Bool`, using conjunction.
     */
    public static var andSemigroup : AndSemigroup {
        return AndSemigroup()
    }
    
    /**
     Provides an instance of `Monoid` for `Bool`, using conjunction.
     */
    public static var andMonoid : AndMonoid {
        return AndMonoid()
    }
    
    /**
     Provides an instance of `Semigroup` for `Bool`, using disjunction.
     */
    public static var orSemigroup : OrSemigroup {
        return OrSemigroup()
    }
    
    /**
     Provides an instance of `Monoid` for `Bool`, using disjunction.
     */
    public static var orMonoid : OrMonoid {
        return OrMonoid()
    }
    
    /**
     Provides an instance of `Eq` for `Bool`.
     */
    public static var eq : BoolEq {
        return BoolEq()
    }
}
