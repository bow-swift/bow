import Foundation
import Bow

public final class ForMu {}
public typealias MuPartial = ForMu
public typealias MuOf<F> = Kind<ForMu, F>

open class Mu<F>: MuOf<F> {
    public static func fix(_ value: MuOf<F>) -> Mu<F> {
        value as! Mu<F>
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
    Mu.fix(value)
}

extension MuPartial: Recursive {
    public static func projectT<F: Functor>(_ tf: MuOf<F>) -> Kind<F, MuOf<F>> {
        cata(tf, { ff in
            Eval.later { ff.map { f in
                embedT(f.value().map { muf in
                    Eval.now(muf)
                }).value()
            } }
        })
    }
}

extension MuPartial: Corecursive {
    public static func embedT<F: Functor>(_ tf: Kind<F, Eval<MuOf<F>>>) -> Eval<MuOf<F>> {
        .now(MuEmbed(tf))
    }
}

private class MuEmbed<F: Functor>: Mu<F> {
    private let tf: Kind<F, Eval<MuOf<F>>>
    
    init(_ tf: Kind<F, Eval<MuOf<F>>>) {
        self.tf = tf
    }
    
    override func unMu<A>(_ fa: @escaping Algebra<F, Eval<A>>) -> Eval<A> {
        fa(tf.map { eval in eval.flatMap { x in x^.unMu(fa) }^ })
    }
}
