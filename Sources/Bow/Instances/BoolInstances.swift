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

public class OrMonoid : OrSemigroup {
    public var empty : Bool {
        return false
    }
}

public extension Bool {
    public static var andMonoid : AndMonoid {
        return AndMonoid()
    }
    
    public static var orMonoid : OrMonoid {
        return OrMonoid()
    }
}
