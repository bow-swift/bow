import Foundation

/// An atomically modifiable reference to a value
public final class Atomic<A> {
    private let queue = DispatchQueue(label: "Atomic serial queue")
    private var _value: A
    
    /// Initializes an atomic value with an initial value.
    ///
    /// - Parameter value: Initial value for this reference.
    public init(_ value: A) {
        self._value = value
    }

    /// Gets or sets the underlying value in a thread-safe manner.
    public var value: A {
        get {
            return queue.sync { self._value }
        }
        set {
            self._value = newValue
        }
    }

    /// Mutates the underlying value using the provided function.
    ///
    /// - Parameter transform: Transformation function
    public func mutate(_ transform: (inout A) -> ()) {
        queue.sync {
            transform(&self._value)
        }
    }

    /// Gets the underlying value and sets a new value.
    ///
    /// - Parameter newValue: New value to be stored in this atomic reference.
    /// - Returns: Previous value saved in this reference, before the modification.
    public func getAndSet(_ newValue: A) -> A {
        var oldValue: A? = nil
        queue.sync {
            oldValue = self._value
            self._value = newValue
        }
        return oldValue!
    }
    
    /// Gets the underlying value and sets a new value transforming it with a function.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: Previous value saved in this reference, before the modification.
    public func getAndUpdate(_ f: @escaping (A) -> A) -> A {
        var oldValue: A? = nil
        queue.sync {
            oldValue = self._value
            self._value = f(self._value)
        }
        return oldValue!
    }
    
    /// Sets a new value in this atomic reference and gets the newly updated value.
    ///
    /// - Parameter newValue: Value to be set in this atomic reference.
    /// - Returns: Newly set value.
    public func setAndGet(_ newValue: A) -> A {
        return updateAndGet { _ in newValue }
    }
    
    /// Sets a new value transforming the underlying one using a function and gets the new value.
    ///
    /// - Parameter f: Transforming value.
    /// - Returns: Value resulting from transforming the underlying value.
    public func updateAndGet(_ f: @escaping (A) -> A) -> A {
        var newValue: A? = nil
        queue.sync {
            self._value = f(self._value)
            newValue = self._value
        }
        return newValue!
    }

    /// Sets a new value if the underlying value is nil
    ///
    /// - Parameter newValue: Value to be set.
    /// - Returns: True if the new value was set; false, otherwise.
    @discardableResult public func setIfNil<AA>(_ newValue: AA) -> Bool where A == AA? {
        var result = false
        queue.sync {
            if self._value == nil {
                self._value = newValue
                result = true
            }
        }
        return result
    }

    /// Sets the underlying value to nil
    public func setNil<AA>() where A == AA? {
        queue.sync {
            self._value = nil
        }
    }
}

extension Atomic where A: Equatable {
    /// Sets a new value if the underlying value is equal to the one passed as a test.
    ///
    /// - Parameters:
    ///   - test: Value to compare with the underlying value.
    ///   - newValue: Value to be set.
    /// - Returns: True if the new value was set; false, otherwise.
    public func compare(_ test: A, andSet newValue: A) -> Bool {
        var equals = false
        queue.sync {
            if _value == test {
                equals = true
                _value = newValue
            }
        }
        return equals
    }
}
