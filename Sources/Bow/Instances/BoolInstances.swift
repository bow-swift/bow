import Foundation

public class AndSemigroup : Semigroup {
    public typealias A = Bool
    
    public func combine(_ a: Bool, _ b: Bool) -> Bool {
        return a && b
    }
}

public class AndMonoid : AndSemigroup, Monoid {
    public var empty : Bool {
        return true
    }
}

public class OrSemigroup : Semigroup {
    public typealias A = Bool
    
    public func combine(_ a: Bool, _ b: Bool) -> Bool {
        return a || b
    }
}

public class OrMonoid : OrSemigroup, Monoid {
    public var empty : Bool {
        return false
    }
}

public class BoolEq : Eq {
    public typealias A = Bool
    
    public func eqv(_ a: Bool, _ b: Bool) -> Bool {
        return a == b
    }
}

public extension Bool {
    public static var andSemigroup : AndSemigroup {
        return AndSemigroup()
    }
    
    public static var andMonoid : AndMonoid {
        return AndMonoid()
    }
    
    public static var orSemigroup : OrSemigroup {
        return OrSemigroup()
    }
    
    public static var orMonoid : OrMonoid {
        return OrMonoid()
    }
    
    public static var eq : BoolEq {
        return BoolEq()
    }
}
