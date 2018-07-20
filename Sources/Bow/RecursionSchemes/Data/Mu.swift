import Foundation

public class ForMu {}
public typealias MuOf<F> = Kind<ForMu, F>

open class Mu<F> : MuOf<F> {
    open func unMu<A>(_ fa : Algebra<F, Eval<A>>) -> Eval<A> {
        fatalError("unMu must be implemented in subclasses")
    }
}
