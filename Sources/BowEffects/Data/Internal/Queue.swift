import Foundation

internal struct Queue {
//    case queue(DispatchQueue)
//    case current
    
    static func queue(_ queue: DispatchQueue = .main) -> Queue {
        queue.setSpecific(key: Key.threadLabel, value: queue.label)
        return .init(queue: ._queue(queue))
    }
    
    /* convenience */ static func queue(label: String, qos: DispatchQoS = .default) -> Queue {
        queue(DispatchQueue(label: label, qos: qos))
    }
    
    static var current: Queue {
        .init(queue: ._current)
    }
    
    // MARK: cases
    private let queue: _Queue
    
    private enum _Queue {
        case _queue(DispatchQueue)
        case _current
    }
    
    // MARK: properties
    var label: String {
        switch queue {
        case ._queue(let queue):
            return queue.label
        case ._current:
            return DispatchQueue.currentLabel
        }
    }
    
    var qos: DispatchQoS {
        switch queue {
        case ._queue(let queue):
            return queue.qos
        case ._current:
            return .default
        }
    }
    
    // MARK: operations
    func async(execute work: @escaping () -> Void) {
        switch queue {
        case ._queue(let queue):
            queue.async(execute: work)
        default:
            fatalError("can not execute async work in current queue")
        }
    }
    
    func sync<T>(execute work: () throws -> T) rethrows -> T {
        switch queue {
        case ._queue(let queue):
            if DispatchQueue.currentLabel == queue.label {
                return try work()
            } else {
                return try queue.sync(execute: work)
            }
        case ._current:
            return try work()
        }
    }
    
    
    fileprivate enum Key {
        static let threadLabel = DispatchSpecificKey<String>()
    }
}


// MARK: - helpers
internal extension DispatchQueue {
    var queue: Queue {
        .queue(self)
    }
}

public extension DispatchQueue {
    static var currentLabel: String {
        DispatchQueue.getSpecific(key: Queue.Key.threadLabel) ?? "unknown-\(Date().timeIntervalSince1970)"
    }
}
