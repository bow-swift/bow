/// A binding expression is one of the instructions of the form `x <- fx` in a monad comprehension.
///
/// In a binding expression of the form `x <- fx`, `x` is the variable to be bound and `fx` is the
/// monadic effect that we want to bind to the variable.
public class BindingExpression<F: Monad> {
    internal let bound: BoundVar<F, Any>
    
    init(_ bound: BoundVar<F, Any>) {
        self.bound = bound
    }
    
    func bind(_ fa: Kind<F, Any>, in bound: BoundVar<F, Any>) -> Kind<F, Any> {
        fatalError("bind must be implemented in subclasses")
    }
}

class MonadBindingExpression<F: Monad>: BindingExpression<F> {
    internal let fa: () -> Kind<F, Any>
    
    public init(_ bound: BoundVar<F, Any>, _ fa: @escaping () -> Kind<F, Any>) {
        self.fa = fa
        super.init(bound)
    }
    
    override func bind(_ fa: Kind<F, Any>, in bound: BoundVar<F, Any>) -> Kind<F, Any> {
        return fa.flatMap{ x in
            bound.bind(x)
            return self.fa()
        }
    }
}
