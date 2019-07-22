class MonadComprehension<F: Monad> {
    static func buildBlock<A>(_ children: [BindingExpression<F>], yield: @escaping () -> A) -> Kind<F, A> {
        let last = go(children, F.pure(()), BoundVar())
        return last.0.map { a in
            last.1.bind(a)
            return yield()
        }
    }
    
    private static func go(_ children: [BindingExpression<F>], _ fa: Kind<F, Any>, _ bound: BoundVar<F, Any>) -> (Kind<F, Any>, BoundVar<F, Any>) {
        if let first = children.first {
            let rest = Array(children.dropFirst())
            return go(rest, first.bind(fa, in: bound), first.bound)
        } else {
            return (fa, bound)
        }
    }
}

public func binding<F: Monad, A>(_ instructions: BindingExpression<F>..., yield value: @autoclosure @escaping () -> A) -> Kind<F, A> {
    return MonadComprehension<F>.buildBlock(instructions, yield: value)
}
