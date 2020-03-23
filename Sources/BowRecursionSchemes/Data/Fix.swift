import Foundation
import Bow

public final class ForFix {}
public typealias FixPartial = ForFix
public typealias FixOf<A> = Kind<ForFix, A>

public class Fix<A>: FixOf<A> {
    public let unFix: Kind<A, Eval<FixOf<A>>>
    
    public static func fix(_ value: FixOf<A>) -> Fix<A> {
        value as! Fix<A>
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
    Fix.fix(value)
}

extension FixPartial: Recursive {
    public static func projectT<F: Functor>(_ tf: FixOf<F>) -> Kind<F, FixOf<F>> {
        F.map(tf^.unFix, { x in x.value() })
    }
}

extension FixPartial: Corecursive {
    public static func embedT<F: Functor>(_ tf: Kind<F, Eval<FixOf<F>>>) -> Eval<FixOf<F>> {
        Eval.later { Fix(unFix: tf) }
    }
}
