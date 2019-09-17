import Bow

/// Ref is an asynchronous, concurrent mutable reference in the context of `F` holding a value of type `A`. Provides safe concurrent access and modification of its content. `Ref`is a purely functional wrapper over an `Atomic<A>` in context `F` that is always initialized to a value.
public class Ref<F, A> {
    /// Obtains the current value. Since `Ref` is always guaranteed to have a value, the returned action completes immetiately after being bound.
    ///
    /// - Returns: A computation that provides the underlying value.
    public func get() -> Kind<F, A> {
        fatalError("get must be implemented in subclasses")
    }
    
    /// Sets the current value to a new value. The returned action completes after the reference has been successfully set.
    ///
    /// - Parameter a: New value to be set.
    /// - Returns: A computation that sets the underlying value.
    public func set(_ a: A) -> Kind<F, ()> {
        fatalError("set must be implemented in subclasses")
    }
    
    /// Replaces the current value, returning the old value.
    ///
    /// - Parameter a: New value to be set.
    /// - Returns: A computation that provides the old value saved in this reference.
    public func getAndSet(_ a: A) -> Kind<F, A> {
        fatalError("getAndSet must be implemented in subclasses")
    }
    
    /// Replaces the current value, returning the new value.
    ///
    /// - Parameter a: New value to be set.
    /// - Returns: A computation that provides the new value saved in this reference.
    public func setAndGet(_ a: A) -> Kind<F, A> {
        fatalError("setAndGet must be implemented in subclasses")
    }
    
    /// Updates the current value with a function. If another modification occurs between the time the current value is read and subsequently updated, the modification is retried using the new value. Hence, the function may be invoked multiple times.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A computation that updates the underlying value using the provided function.
    public func update(_ f: @escaping (A) -> A) -> Kind<F, ()> {
        fatalError("update must be implemented in subclasses")
    }
    
    /// Modifies the current value using the supplied update function and returns the old value.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A computation that provides the old value saved in this reference.
    public func getAndUpdate(_ f: @escaping (A) -> A) -> Kind<F, A> {
        fatalError("getAndUpdate must be implemented in subclasses")
    }
    
    /// Modifies the current value using the supplied update function and returns the new value.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A computation that provides the new value saved in this reference.
    public func updateAndGet(_ f: @escaping (A) -> A) -> Kind<F, A> {
        fatalError("updateAndGet must be implemented in subclasses")
    }
    
    /// Updates the reference but allows the function to return an output of a different type.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A computation that updates the underlying value using the provided function.
    public func modify<B>(_ f: @escaping (A) -> (A, B)) -> Kind<F, B> {
        fatalError("modify must be implemented in subclasses")
    }
    
    /// Tries to modify the current value once, in contrast to update which calls the function until it succeeds.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A computation that contains a flag indicating if the update was possible or not.
    public func tryUpdate(_ f: @escaping (A) -> A) -> Kind<F, Bool> {
        fatalError("tryUpdate must be implemented in subclasses")
    }
    
    /// Tries to modify the current value once, in contrast to modify which calls the function until it succeeds.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: A computation that provides an optional value with the result of the modification, if it happened.
    public func tryModify<B>(_ f: @escaping (A) -> (A, B)) -> Kind<F, Option<B>> {
        fatalError("tryModify must be implemented in subclasses")
    }
    
    /// Obtains a snapshot of the current value and a setter for updating it. The setter will return false if another concurrent call invalidated the snapshot; i.e. modified the value. It will return true if setting the value was successful. Once it has returned false or been used once, a setter never succeeds again.
    ///
    /// - Returns: A computation providing a value and a setter.
    public func access() -> Kind<F, (A, (A) -> Kind<F, Bool>)> {
        fatalError("access must be implemented in subclasses")
    }
}

// MARK: Methods to create a `Ref` from a `MonadDefer`.

public extension Ref where F: MonadDefer, A: Equatable {
    /// Safely creates a `Ref`.
    ///
    /// - Parameter f: Function providing the initial value for the reference.
    /// - Returns: A computation that provides the `Ref`.
    static func of(_ f: @autoclosure @escaping () -> A) -> Kind<F, Ref<F, A>> {
        return F.later { unsafe(f()) }
    }
    
    /// Unsafely creates a `Ref`.
    ///
    /// - Parameter a: Initial value for the reference.
    /// - Returns: A `Ref` containing the initial value.
    static func unsafe(_ a: A) -> Ref<F, A> {
        return MonadDeferRef(Atomic(a))
    }
}

private class MonadDeferRef<F: MonadDefer, A: Equatable>: Ref<F, A> {
    private let atomic: Atomic<A>
    
    init(_ atomic: Atomic<A>) {
        self.atomic = atomic
    }
    
    override func get() -> Kind<F, A> {
        return F.later { self.atomic.value }
    }
    
    override func set(_ a: A) -> Kind<F, ()> {
        return F.later { self.atomic.value = a }
    }
    
    override func getAndSet(_ a: A) -> Kind<F, A> {
        return F.later { self.atomic.getAndSet(a) }
    }
    
    override func setAndGet(_ a: A) -> Kind<F, A> {
        return set(a).flatMap { self.get() }
    }
    
    override func update(_ f: @escaping (A) -> A) -> Kind<F, ()> {
        return modify { a in (f(a), ()) }
    }
    
    override func getAndUpdate(_ f: @escaping (A) -> A) -> Kind<F, A> {
        return F.later { self.atomic.getAndUpdate(f) }
    }
    
    override func updateAndGet(_ f: @escaping (A) -> A) -> Kind<F, A> {
        return F.later { self.atomic.updateAndGet(f) }
    }
    
    override func modify<B>(_ f: @escaping (A) -> (A, B)) -> Kind<F, B> {
        func go() -> B {
            let a = atomic.value
            let (u, b) = f(a)
            return atomic.compare(a, andSet: u) ? b : go()
        }
        
        return F.later(go)
    }
    
    override func tryUpdate(_ f: @escaping (A) -> A) -> Kind<F, Bool> {
        return tryModify { a in (f(a), ()) }.map { x in x.isDefined }
    }
    
    override func tryModify<B>(_ f: @escaping (A) -> (A, B)) -> Kind<F, Option<B>> {
        return F.later {
            let a = self.atomic.value
            let (u, b) = f(a)
            return self.atomic.compare(a, andSet: u) ? Option.some(b) : Option.none()
        }
    }
    
    override func access() -> Kind<F, (A, (A) -> Kind<F, Bool>)> {
        return F.later {
            let snapshot = self.atomic.value
            let hasBeenCalled = Atomic(false)
            let setter = { (a: A) in F.later { hasBeenCalled.compare(false, andSet: true) && self.atomic.compare(snapshot, andSet: a) } }
            return (snapshot, setter)
        }
    }
}
