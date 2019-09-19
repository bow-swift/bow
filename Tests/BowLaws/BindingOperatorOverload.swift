@testable import Bow

infix operator <-- : AssignmentPrecedence

public func <--<F: Monad, A>(_ bound: BoundVar<F, A>, _ fa: @autoclosure @escaping () -> Kind<F, A>) -> BindingExpression<F> {
    return bound <- fa()
}

public func <--<F: Monad, A>(_ bound: BoundVar<F, A>, _ fa: @autoclosure @escaping () -> A) -> BindingExpression<F> {
    return bound <- fa()
}

public func <--<F: Monad, A, B>(_ bound: (BoundVar<F, A>, BoundVar<F, B>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B)>) -> BindingExpression<F> {
    return bound <- fa()
}
