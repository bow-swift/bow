public func getState<F: MonadState>() -> Kind<F, F.S> {
    return F.get()
}

public func setState<F: MonadState>(_ state: F.S) -> BindingExpression<F> {
    return |<-F.set(state)
}

public func modifyState<F: MonadState>(_ f: @escaping (F.S) -> F.S) -> BindingExpression<F> {
    return |<-F.modify(f)
}

public func inspectState<F: MonadState, A>(_ f: @escaping (F.S) -> A) -> Kind<F, A> {
    return F.inspect(f)
}
