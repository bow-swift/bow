/// A binding expression is one of the instructions of the form `x <- fx` in a monad comprehension.
///
/// In a binding expression of the form `x <- fx`, `x` is the variable to be bound and `fx` is the
/// monadic effect that we want to bind to the variable.
public class BindingExpression<F: Monad> {
    internal let bound: BoundVar<F, Any>
    internal let fa: () -> Kind<F, Any>
    
    init(_ bound: BoundVar<F, Any>, _ fa: @escaping () -> Kind<F, Any>) {
        self.bound = bound
        self.fa = fa
    }
    
    internal func yield<A>(_ f: @escaping () -> A) -> Kind<F, A> {
        return fa().map { x in
            self.bound.bind(x)
            return f()
        }
    }
    
    internal func bind<A>(_ partial: Eval<Kind<F, A>>) -> Kind<F, A> {
        return fa().flatMap { x in
            self.bound.bind(x)
            return partial.value()
        }
    }
}
