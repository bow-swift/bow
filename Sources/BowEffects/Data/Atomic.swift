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

    func getAndSet(_ newValue: A) -> A {
        var oldValue: A? = nil
        queue.sync {
            oldValue = self._value
            self._value = newValue
        }
        return oldValue!
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
    func compareAndSet(_ check: A, _ newValue: A) -> Bool {
        var result = false
        queue.sync {
            if _value == check {
                _value = newValue
                result = true
            }
        }
        return result
    }
}
