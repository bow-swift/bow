internal class ReaderBindingExpression<F: MonadReader>: BindingExpression<F> {
    let f: (F.D) -> F.D
    
    init(_ f: @escaping (F.D) -> F.D) {
        self.f = f
        super.init(BoundVar())
    }
    
    override func bind(_ fa: Kind<F, Any>, in bound: BoundVar<F, Any>) -> Kind<F, Any> {
        return fa.flatMap { x in
            bound.bind(x)
            return fa.local(self.f)
        }
    }
}

/// Utility alias for `MonadReader.ask` in a monad comprehension.
///
/// - Returns: Result of `MonadReader.ask`.
public func askReader<F: MonadReader>() -> Kind<F, F.D> {
    return F.ask()
}

/// Utility alias for `MonadReader.local` in a monad comprehension.
///
/// - Parameter f: Function for `MonadReader.local`.
/// - Returns: A binding expression.
public func localReader<F: MonadReader>(_ f: @escaping (F.D) -> F.D) -> BindingExpression<F> {
    return ReaderBindingExpression(f)
}
