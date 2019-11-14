// type Pairing f g = forall a b. f (a -> b) -> g a -> b

public final class ForPairing {}
public final class PairingPartial<F: Functor>: Kind<ForPairing, F> {}
public typealias PairingOf<F: Functor, G: Functor> =  Kind<PairingPartial<F>, G>

public class Pairing<F: Functor, G: Functor> : PairingOf<F, G> {
    internal let pair : (Kind<F, (/*A*/Any) -> /*B*/Any>) -> (Kind<G, /*A*/Any>) -> /*B*/Any
    
    public static func fix(_ value : PairingOf<F, G>) -> Pairing<F, G> {
        value as! Pairing<F, G>
    }
    
    public init(_ pair: @escaping (Kind<F, (/*A*/Any) -> /*B*/Any>) -> (Kind<G, /*A*/Any>) -> /*B*/Any) {
        self.pair = pair
    }
    
    /// Annihalate the `F` and `G` effects effectively calling the wrapped function in `F` with the wrapped value
    ///
    /// - Parameter fab: An `F`-effectful `A -> B`
    /// - Parameter ga: A `G`-effectful `A`
    /// - Returns: A pure `B`
    public func zap<A, B>(_ fab: Kind<F, (A) -> B>, ga: Kind<G, A>) -> B {
        let gany = ga.map{ $0 as Any }
        let fany =
            fab.map{ aArrb in { (any: Any) in
                aArrb(any as! A) as Any}}
        return self.pair(fany)(gany) as! B
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Pairing.
public postfix func ^<F, G>(_ value: PairingOf<F, G>) -> Pairing<F, G> {
    return Pairing.fix(value)
}