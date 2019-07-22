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

public func askReader<F: MonadReader>() -> Kind<F, F.D> {
    return F.ask()
}

public func localReader<F: MonadReader>(_ f: @escaping (F.D) -> F.D) -> BindingExpression<F> {
    return ReaderBindingExpression(f)
}
