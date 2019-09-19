/// Utility function for `MonadWriter.tell` in monad comprehensions.
///
/// - Parameter w: Value for `MonadWriter.tell`.
/// - Returns: A binding expression.
public func tell<F: MonadWriter>(_ w: F.W) -> BindingExpression<F> {
    return |<-F.tell(w)
}
