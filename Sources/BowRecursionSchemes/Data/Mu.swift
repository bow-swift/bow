import Foundation
import Bow

public final class ForMu {}
public typealias MuOf<F> = Kind<ForMu, F>

open class Mu<F>: MuOf<F> {
    public static func fix(_ value: MuOf<F>) -> Mu<F> {
        return value as! Mu<F>
    }
    
    open func unMu<A>(_ fa: @escaping Algebra<F, Eval<A>>) -> Eval<A> {
        fatalError("unMu must be implemented in subclasses")
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Mu.
public postfix func ^<F>(_ value: MuOf<F>) -> Mu<F> {
    return Mu.fix(value)
}

extension ForMu: Recursive {
    public static func projectT<F: Functor>(_ tf: Kind<ForMu, F>) -> Kind<F, Kind<ForMu, F>> {
        return cata(tf, { ff in
            Eval.later { F.map(ff, { f in
                embedT(F.map(f.value(), { muf in
                    Eval.now(muf)
                })).value()
            }) }
        })
    }
}

extension ForMu: Corecursive {
    public static func embedT<F: Functor>(_ tf: Kind<F, Eval<Kind<ForMu, F>>>) -> Eval<Kind<ForMu, F>> {
        return Eval.now(MuEmbed(tf))
    }
}

private class MuEmbed<F: Functor> : Mu<F> {
    private let tf: Kind<F, Eval<Kind<ForMu, F>>>
    
    init(_ tf: Kind<F, Eval<Kind<ForMu, F>>>) {
        self.tf = tf
    }
    
    override func unMu<A>(_ fa: @escaping Algebra<F, Eval<A>>) -> Eval<A> {
        return fa(F.map(tf, { eval in Eval.fix(eval.flatMap { x in Mu.fix(x).unMu(fa) }) }))
    }
}
