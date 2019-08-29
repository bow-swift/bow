@testable import Bow

infix operator <-- : AssignmentPrecedence

public func <--<F: Monad, A>(_ bound: BoundVar<F, A>, _ fa: @autoclosure @escaping () -> Kind<F, A>) -> BindingExpression<F> {
    return bound <- fa()
}

public func <--<F: Monad, A>(_ bound: BoundVar<F, A>, _ fa: @autoclosure @escaping () -> A) -> BindingExpression<F> {
    return bound <- fa()
}

public func <--<F: MonadWriter, A, B>(_ bounds: (BoundVar<F, B>, BoundVar<F, A>), _ handler: ListenHandler<F, B>) -> BindingExpression<F> {
    return bounds <- handler
}

public func <--<F: MonadWriter, A>(_ bound: BoundVar<F, A>, _ handler: CensorHandler<F>) -> BindingExpression<F> {
    return bound <- handler
}
