/// The ComonadTrans type class represents Comonad Transformers.
public protocol ComonadTrans: Comonad {
    /// The input type parameter of this transformer.
    associatedtype W: Comonad

    /// Obtains the comonadic value contained in the provided comonad transformer.
    ///
    /// - Parameter twa: Value containing another comonadic value.
    /// - Returns: Contained comonadic value within the transformer.
    static func lower<A>(_ twa: Kind<Self, A>) -> Kind<W, A>
}

// MARK: Syntax for ComonadTrans

public extension Kind where F: ComonadTrans {
    /// Obtains the comonadic value contained in the provided comonad transformer.
    ///
    /// - Returns: Contained comonadic value within the transformer.
    func lower() -> Kind<F.W, A> {
        F.lower(self)
    }
}
