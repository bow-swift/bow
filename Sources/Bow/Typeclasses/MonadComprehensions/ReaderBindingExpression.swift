/// Utility alias for `MonadReader.ask` in a monad comprehension.
///
/// - Returns: Result of `MonadReader.ask`.
public func ask<F: MonadReader>() -> Kind<F, F.D> {
    return F.ask()
}
