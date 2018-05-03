import Foundation

public class BoundSetter<S, A> {
    let value : S
    let setter : Setter<S, A>
    
    public init(value : S, setter : Setter<S, A>) {
        self.value = value
        self.setter = setter
    }
    
    public func modify(_ f : @escaping (A) -> A) -> S {
        return setter.modify(value, f)
    }
    
    public func set(_ a : A) -> S {
        return setter.set(value, a)
    }
    
    public func compose<T>(_ other : Setter<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
    
    public func compose<T>(_ other : Optional<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
    
    public func compose<T>(_ other : Prism<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
    
    public func compose<T>(_ other : Lens<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
    
    public func compose<T>(_ other : Iso<A, T>) -> BoundSetter<S, T> {
        return BoundSetter<S, T>(value: value, setter: setter + other)
    }
}
