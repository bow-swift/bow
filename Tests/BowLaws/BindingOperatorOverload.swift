@testable import Bow

infix operator <-- : AssignmentPrecedence

/// Creates a binding expression.
///
/// - Parameters:
///   - bound: Variable to be bound in the expression.
///   - fa: Monadic effect.
/// - Returns: A binding expression.
public func <--<F: Monad, A>(_ bound: BoundVar<F, A>, _ fa: @autoclosure @escaping () -> Kind<F, A>) -> BindingExpression<F> {
    return bound <- fa()
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 2-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <--<F: Monad, A, B>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B)>) -> BindingExpression<F> {
    return bounds <- fa()
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 3-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <--<F: Monad, A, B, C>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C)>) -> BindingExpression<F> {
    return bounds <- fa()
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 4-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <--<F: Monad, A, B, C, D>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D)>) -> BindingExpression<F> {
    return bounds <- fa()
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 5-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <--<F: Monad, A, B, C, D, E>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E)>) -> BindingExpression<F> {
    return bounds <- fa()
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 6-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <--<F: Monad, A, B, C, D, E, G>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G)>) -> BindingExpression<F> {
    return bounds <- fa()
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 7-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <--<F: Monad, A, B, C, D, E, G, H>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H)>) -> BindingExpression<F> {
    return bounds <- fa()
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 8-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <--<F: Monad, A, B, C, D, E, G, H, I>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>, BoundVar<F, I>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H, I)>) -> BindingExpression<F> {
    return bounds <- fa()
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 9-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <--<F: Monad, A, B, C, D, E, G, H, I, J>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>, BoundVar<F, I>, BoundVar<F, J>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H, I, J)>) -> BindingExpression<F> {
    return bounds <- fa()
}

/// Creates a binding expression.
///
/// - Parameters:
///   - bounds: A 10-ary tuple of variables to be bound to the values produced by the effect.
///   - fa: Monadic effect.
/// - Returns: A binding expresssion.
public func <--<F: Monad, A, B, C, D, E, G, H, I, J, K>(_ bounds: (BoundVar<F, A>, BoundVar<F, B>, BoundVar<F, C>, BoundVar<F, D>, BoundVar<F, E>, BoundVar<F, G>, BoundVar<F, H>, BoundVar<F, I>, BoundVar<F, J>, BoundVar<F, K>), _ fa: @autoclosure @escaping () -> Kind<F, (A, B, C, D, E, G, H, I, J, K)>) -> BindingExpression<F> {
    return bounds <- fa()
}
