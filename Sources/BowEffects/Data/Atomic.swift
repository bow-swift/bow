import Foundation

final class Atomic<A> {
    private let queue = DispatchQueue(label: "Atomic serial queue")
    private var _value: A
    init(_ value: A) {
        self._value = value
    }

    var value: A {
        get {
            return queue.sync { self._value }
        }
    }

    func mutate(_ transform: (inout A) -> ()) {
        queue.sync {
            transform(&self._value)
        }
    }
    
    func set(_ newValue: A) {
        queue.sync {
            self._value = newValue
        }
    }

    func getAndSet(_ newValue: A) -> A {
        var oldValue: A? = nil
        queue.sync {
            oldValue = self._value
            self._value = newValue
        }
        return oldValue!
    }
    
    func getAndUpdate(_ f: @escaping (A) -> A) -> A {
        var oldValue: A? = nil
        queue.sync {
            oldValue = self._value
            self._value = f(self._value)
        }
        return oldValue!
    }
    
    func updateAndGet(_ f: @escaping (A) -> A) -> A {
        var newValue: A? = nil
        queue.sync {
            self._value = f(self._value)
            newValue = self._value
        }
        return newValue!
    }

    func setIfNil<AA>(_ newValue: AA) -> Bool where A == AA? {
        var result = false
        queue.sync {
            if self._value == nil {
                self._value = newValue
                result = true
            }
        }
        return result
    }

    func setNil<AA>() where A == AA? {
        queue.sync {
            self._value = nil
        }
    }
}

extension Atomic where A: Equatable {
    func compare(_ test: A, andSet newValue: A) -> Bool {
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