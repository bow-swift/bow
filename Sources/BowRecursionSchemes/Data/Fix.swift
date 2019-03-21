import Foundation
import Bow

public final class ForFix {}
public typealias FixOf<A> = Kind<ForFix, A>

public class Fix<A>: FixOf<A> {
    public let unFix: Kind<A, Eval<FixOf<A>>>
    
    public static func fix(_ value: FixOf<A>) -> Fix<A> {
        return value as! Fix<A>
    }
    
    public init(unFix: Kind<A, Eval<FixOf<A>>>) {
        self.unFix = unFix
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Fix.
public postfix func ^<A>(_ value: FixOf<A>) -> Fix<A> {
    return Fix.fix(value)
}

extension ForFix: Recursive {
    public static func projectT<F: Functor>(_ tf: Kind<ForFix, F>) -> Kind<F, Kind<ForFix, F>> {
        return F.map(Fix.fix(tf).unFix, { x in x.value() })
    }
}

extension ForFix: Corecursive {
    public static func embedT<F: Functor>(_ tf: Kind<F, Eval<Kind<ForFix, F>>>) -> Eval<Kind<ForFix, F>> {
        return Eval.later { Fix(unFix: tf) }
    }
}
