import Foundation

/// Partial application of the `State` type constructor, omitting the last parameter.
public typealias StatePartial<S> = StateTPartial<ForId, S>

/// Higher Kinded Type alias to improve readability over `StateT<ForId, S, A>`.
public typealias StateOf<S, A> = StateT<ForId, S, A>

/// State is a convenience data type over the `StateT` transformer, when the effect is `Id`.
public class State<S, A>: StateOf<S, A> {
    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to State.
    public static func fix(_ value: StateOf<S, A>) -> State<S, A> {
        return value as! State<S, A>
    }
    
    /// Initializes a `State` value.
    ///
    /// - Parameter run: A function that depends on a state and produces a new state and a value.
    public init(_ run: @escaping (S) -> (S, A)) {
        super.init(Id.pure({ s in Id.pure(run(s)) }))
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to State.
public postfix func ^<S, A>(_ value: StateOf<S, A>) -> State<S, A> {
    return State.fix(value)
}
