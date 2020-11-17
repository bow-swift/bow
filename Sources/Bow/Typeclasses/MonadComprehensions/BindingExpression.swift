/// A binding expression is one of the instructions of the form `x <- fx` in a monad comprehension.
///
/// In a binding expression of the form `x <- fx`, `x` is the variable to be bound and `fx` is the
/// monadic effect that we want to bind to the variable.
public class BindingExpression<F: Monad> {
    private let exists: Exists<_BindingExpressionPartial<F>>

    init<A>(_ bound: BoundVar<F, A>, _ fa: @escaping () -> Kind<F, A>) {
        self.exists = Exists(_BindingExpression(bound: bound, fa: fa))
    }
    
    internal func yield<A>(_ f: @escaping () -> A) -> Kind<F, A> {
        exists.run(Yield(f))
    }
    
    internal func bind<A>(_ partial: Eval<Kind<F, A>>) -> Kind<F, A> {
        exists.run(Bind(partial))
    }
}

private final class Yield<F: Monad, A>: CokleisliK<_BindingExpressionPartial<F>, Kind<F, A>> {
    init(_ f: @escaping () -> A) {
        self.f = f
    }

    let f: () -> A

    override func invoke<R>(_ existential: _BindingExpressionOf<F, R>) -> Kind<F, A> {
        existential^.fa().map { x in
            existential^.bound.bind(x)
            return self.f()
        }
    }
}

private final class Bind<F: Monad, A>: CokleisliK<_BindingExpressionPartial<F>, Kind<F, A>> {
    init(_ partial: Eval<Kind<F, A>>) {
        self.partial = partial
    }

    let partial: Eval<Kind<F, A>>

    override func invoke<R>(_ existential: _BindingExpressionOf<F, R>) -> Kind<F, A> {
        existential^.fa().flatMap { x in
            existential^.bound.bind(x)
            return self.partial.value()
        }
    }
}

private final class _ForBindingExpression {}
private final class _BindingExpressionPartial<F: Monad>: Kind<_ForBindingExpression, F> {}
private typealias _BindingExpressionOf<F: Monad, A> = Kind<_BindingExpressionPartial<F>, A>
private final class _BindingExpression<F: Monad, A>: _BindingExpressionOf<F, A> {
    init(bound: BoundVar<F, A>, fa: @escaping () -> Kind<F, A>) {
        self.bound = bound
        self.fa = fa
    }

    let bound: BoundVar<F, A>
    let fa: () -> Kind<F, A>
}

private postfix func ^<F, A>(_ fa: _BindingExpressionOf<F, A>) -> _BindingExpression<F, A> {
    fa as! _BindingExpression<F, A>
}
