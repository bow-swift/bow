import Foundation

public class ForFix {}
public typealias FixOf<A> = Kind<ForFix, A>

public class Fix<A> : FixOf<A> {
    public let unFix : Kind<A, Eval<FixOf<A>>>
    
    public static func fix(_ value : FixOf<A>) -> Fix<A> {
        return value as! Fix<A>
    }
    
    public init(unFix : Kind<A, Eval<FixOf<A>>>) {
        self.unFix = unFix
    }
}

public extension Kind where F == ForFix {
    public func fix() -> Fix<A> {
        return Fix<A>.fix(self)
    }
}
