@testable import Bow

infix operator <-- : AssignmentPrecedence

public func <--<F: Monad, A>(_ bound: BoundVar<F, A>, _ fa: @autoclosure @escaping () -> Kind<F, A>) -> BindingExpression<F> {
    return MonadBindingExpression(bound.erased, fa >>> erased)
}
