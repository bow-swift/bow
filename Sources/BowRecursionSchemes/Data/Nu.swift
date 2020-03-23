import Foundation
import Bow

public final class ForNu {}
public typealias NuPartial = ForNu
public typealias NuOf<F> = Kind<ForNu, F>

public class Nu<F>: NuOf<F> {
    public static func fix(_ value: NuOf<F>) -> Nu<F> {
        value as! Nu<F>
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
    Nu.fix(value)
}

extension NuPartial: Recursive {
    public static func projectT<F: Functor>(_ tf: NuOf<F>) -> Kind<F, NuOf<F>> {
        tf^.unNu(tf^.a).map { x in Nu<F>(x, tf^.unNu) }
    }
}

extension NuPartial: Corecursive {
    public static func embedT<F: Functor>(_ tf: Kind<F, Eval<NuOf<F>>>) -> Eval<NuOf<F>> {
        .now(Nu<F>(tf, { f in
            f.map { nu in
                projectT(nu.value()).map(Eval.now)
            }
        }))
    }
}
