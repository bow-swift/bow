import Foundation

/// A MonadState is a `Monad` that maintains a state.
public protocol MonadState: Monad {
    /// Type of the state maintained in this instance
    associatedtype S

    /// Retrieves the state from the internals of the monad.
    ///
    /// - Returns: Maintained state.
    static func get() -> Kind<Self, S>

    /// Replaces the state inside the monad.
    ///
    /// - Parameter s: New state.
    /// - Returns: Unit.
    static func set(_ s: S) -> Kind<Self, ()>
}

public extension MonadState {
    /// Embeds a state action into the monad.
    ///
    /// - Parameter f: A function that receives the state and computes a value and a new state.
    /// - Returns: A value with the output of the function and the new state.
    static func state<A>(_ f: @escaping (S) -> (S, A)) -> Kind<Self, A> {
        return flatMap(get(), { s in
            let result = f(s)
            return map(set(result.0), { _ in result.1 })
        })
    }

    /// Modifies the internal state.
    ///
    /// - Parameter f: Function that modifies the state.
    /// - Returns: Unit.
    static func modify(_ f: @escaping (S) -> S) -> Kind<Self, ()> {
        return flatMap(get(), { s in set(f(s))})
    }

    /// Retrieves a specific component of the state.
    ///
    /// - Parameter f: Projection function to obtain part of the state.
    /// - Returns: A specific part of the state.
    static func inspect<A>(_ f: @escaping (S) -> A) -> Kind<Self, A> {
        return map(get(), f)
    }
}

// MARK: Syntax for MonadState

public extension Kind where F: MonadState {
    /// Retrieves the state from the internals of the monad.
    ///
    /// This is a convenience method to call `MonadState.get` as a static method of this type.
    ///
    /// - Returns: Maintained state.
    static func get() -> Kind<F, F.S> {
        return F.get()
    }

    /// Replaces the state inside the monad.
    ///
    /// This is a convenience method to call `MonadState.set` as a static method of this type.
    ///
    /// - Parameter s: New state.
    /// - Returns: Unit.
    static func set(_ s: F.S) -> Kind<F, ()> {
        return F.set(s)
    }

    /// Embeds a state action into the monad.
    ///
    /// This is a convenience method to call `MonadState.state` as a static method of this type.
    ///
    /// - Parameter f: A function that receives the state and computes a value and a new state.
    /// - Returns: A value with the output of the function and the new state.
    static func state(_ f: @escaping (F.S) -> (F.S, A)) -> Kind<F, A> {
        return F.state(f)
    }

    /// Modifies the internal state.
    ///
    /// This is a convenience method to call `MonadState.modify` as a static method of this type.
    ///
    /// - Parameter f: Function that modifies the state.
    /// - Returns: Unit.
    static func modify(_ f: @escaping (F.S) -> F.S) -> Kind<F, ()> {
        return F.modify(f)
    }

    /// Retrieves a specific component of the state.
    ///
    /// This is a convenience method to call `MonadState.inspect` as a static method of this type.
    ///
    /// - Parameter f: Projection function to obtain part of the state.
    /// - Returns: A specific part of the state.
    static func inspect(_ f: @escaping (F.S) -> A) -> Kind<F, A> {
        return F.inspect(f)
    }
}
