/// Utility function for `MonadState.get` in monad comprehensions.
///
/// - Returns: Result from `MonadState.get`.
public func getState<F: MonadState>() -> Kind<F, F.S> {
    return F.get()
}

/// Utility function for `MonadState.set` in monad comprehensions.
///
/// - Parameter state: State to be set in `MonadState.set`.
/// - Returns: A binding expression.
public func setState<F: MonadState>(_ state: F.S) -> BindingExpression<F> {
    return |<-F.set(state)
}

/// Utility function for `MonadState.modify` in monad comprehensions.
///
/// - Parameter f: Function for `MonadState.modify`.
/// - Returns: A binding expression.
public func modifyState<F: MonadState>(_ f: @escaping (F.S) -> F.S) -> BindingExpression<F> {
    return |<-F.modify(f)
}

/// Utility function for `MonadState.inspect` in monad comprehensions.
///
/// - Parameter f: Function for `MonadState.inspect`.
/// - Returns: Result from `MonadState.inspect`.
public func inspectState<F: MonadState, A>(_ f: @escaping (F.S) -> A) -> Kind<F, A> {
    return F.inspect(f)
}
