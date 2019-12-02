// type Pairing f g = forall a b. f (a -> b) -> g a -> b

final class ForPairing {}
final class PairingPartial<F: Functor>: Kind<ForPairing, F> {}
typealias PairingOf<F: Functor, G: Functor> =  Kind<PairingPartial<F>, G>

class Pairing<F: Functor, G: Functor> : PairingOf<F, G> {
    internal let pair : (Kind<F, (/*A*/Any) -> /*B*/Any>) -> (Kind<G, /*A*/Any>) -> /*B*/Any
    
    static func fix(_ value : PairingOf<F, G>) -> Pairing<F, G> {
        value as! Pairing<F, G>
    }
    
    init(_ pair: @escaping (Kind<F, (/*A*/Any) -> /*B*/Any>) -> (Kind<G, /*A*/Any>) -> /*B*/Any) {
        self.pair = pair
    }
    
    /// Annihilate the `F` and `G` effects effectively calling the wrapped function in `F` with the wrapped value
    ///
    /// - Parameter fab: An `F`-effectful `A -> B`
    /// - Parameter ga: A `G`-effectful `A`
    /// - Returns: A pure `B`
    func zap<A, B>(_ fab: Kind<F, (A) -> B>, ga: Kind<G, A>) -> B {
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
postfix func ^<F, G>(_ value: PairingOf<F, G>) -> Pairing<F, G> {
    return Pairing.fix(value)
}
