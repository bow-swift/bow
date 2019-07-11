class MonadComprehension<F: Monad> {
    static func buildBlock<A>(_ children: [BindingExpression<F>], yield: @escaping () -> A) -> Kind<F, A> {
        if let first = children.first {
            let rest = Array(children.dropFirst())
            let last = go(rest, first.fa(), first.bound)
            return last.0.map { a in
                last.1.bind(a)
                return yield()
            }
        } else {
            return F.pure(yield())
        }
    }
    
    private static func go(_ children: [BindingExpression<F>], _ fa: Kind<F, Any>, _ bound: BoundVar<F, Any>) -> (Kind<F, Any>, BoundVar<F, Any>) {
        if let first = children.first {
            let rest = Array(children.dropFirst())
            return go(rest, fa.flatMap{ x in
                bound.bind(x)
                return first.fa()
            }, first.bound)
        } else {
            return (fa, bound)
        }
    }
}

public func binding<F: Monad, A>(_ instructions: BindingExpression<F>..., yield value: @autoclosure @escaping () -> A) -> Kind<F, A> {
    return MonadComprehension<F>.buildBlock(instructions, yield: value)
}
