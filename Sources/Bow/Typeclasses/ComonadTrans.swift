/// The ComonadTrans type class represents Comonad Transformers.
public protocol ComonadTrans {
    /// Obtains the comonadic value contained in the provided comonad transformer.
    ///
    /// - Parameter twa: Value containing another comonadic value.
    /// - Returns: Contained comonadic value within the transformer.
    static func lower<W: Comonad, A, B>(_ twa: Kind<Self, B>) -> Kind<W, A> where B: Kind<W, A>
}

// MARK: Syntax for ComonadTrans

public extension Kind where F: ComonadTrans {
    /// Obtains the comonadic value contained in the provided comonad transformer.
    ///
    /// - Returns: Contained comonadic value within the transformer.
    func lower<W: Comonad, B>() -> Kind<W, B> where A: Kind<W, B> {
        F.lower(self)
    }
}
