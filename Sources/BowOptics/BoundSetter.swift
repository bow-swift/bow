import Foundation
import Bow

/// A BoundSetter is a `Setter` that is already bound to a concrete source.
public class BoundSetter<S, A> {
    /// Bound source.
    let value: S
    
    /// Setter for the source.
    let setter: Setter<S, A>
    
    /// Initializes a BoundSetter.
    ///
    /// - Parameters:
    ///   - value: Bound source.
    ///   - setter: Setter.
    public init(value: S, setter: Setter<S, A>) {
        self.value = value
        self.setter = setter
    }
    
    /// Modifies the source of the bound setter.
    ///
    /// - Parameter f: Function modifying the focus.
    /// - Returns: Modified source.
    public func modify(_ f: @escaping (A) -> A) -> S {
        return setter.modify(value, f)
    }
    
    /// Sets a new value for the focus.
    ///
    /// - Parameter a: New focus.
    /// - Returns: Modified source.
    public func set(_ a: A) -> S {
        return setter.set(value, a)
    }
    
    /// Composes with a `Setter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `BoundSetter` with the same bound source and a `Setter` resulting from the sequential application of the two optics.
    public func compose<T>(_ other: Setter<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
    
    /// Composes with an `Optional`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `BoundSetter` with the same bound source and a `Setter` resulting from the sequential application of the two optics.
    public func compose<T>(_ other: Optional<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
    
    /// Composes with a `Prism`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `BoundSetter` with the same bound source and a `Setter` resulting from the sequential application of the two optics.
    public func compose<T>(_ other: Prism<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
    
    /// Composes with a `Lens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `BoundSetter` with the same bound source and a `Setter` resulting from the sequential application of the two optics.
    public func compose<T>(_ other: Lens<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
    
    /// Composes with an `Iso`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `BoundSetter` with the same bound source and a `Setter` resulting from the sequential application of the two optics.
    public func compose<T>(_ other: Iso<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
}
