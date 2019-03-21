import Foundation
import Bow

public final class ForNu {}
public typealias NuOf<F> = Kind<ForNu, F>

public class Nu<F>: NuOf<F> {
    public static func fix(_ value: NuOf<F>) -> Nu<F> {
        return value as! Nu<F>
    }
    
    public let a: Any
    public let unNu: Coalgebra<F, Any>
    
    public init<A>(_ a: A, _ unNu: @escaping Coalgebra<F, A>) {
        self.a = a
        self.unNu = unNu as! Coalgebra<F, Any>
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Nu.
public postfix func ^<F>(_ value: NuOf<F>) -> Nu<F> {
    return Nu.fix(value)
}

extension ForNu: Recursive {
    public static func projectT<F: Functor>(_ tf: Kind<ForNu, F>) -> Kind<F, Kind<ForNu, F>> {
        let fix = Nu.fix(tf)
        let unNu = fix.unNu
        return F.map(unNu(fix.a), { x in Nu<F>(x, unNu) })
    }
}

extension ForNu: Corecursive {
    public static func embedT<F: Functor>(_ tf: Kind<F, Eval<Kind<ForNu, F>>>) -> Eval<Kind<ForNu, F>> {
        return Eval.now(Nu<F>(tf, { f in
            F.map(f, { nu in
                F.map(projectT(nu.value()), Eval.now)
            })
        }))
    }
}
