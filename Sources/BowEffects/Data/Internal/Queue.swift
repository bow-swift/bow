import Foundation

internal enum Queue {
    case queue(DispatchQueue = .main)
    case current
    
    // MARK: properties
    var label: String {
        switch self {
        case .queue(let queue):
            return queue.label
        case .current:
            return DispatchQueue.currentLabel
        }
    }
    
    var qos: DispatchQoS {
        switch self {
        case .queue(let queue):
            return queue.qos
        case .current:
            return .default
        }
    }
    
    // Mark: constructors
    static func queue(label: String, qos: DispatchQoS = .default) -> Queue {
        .queue(DispatchQueue(label: label, qos: qos))
    }
    
    // MARK: operations
    func async(execute work: @escaping () -> Void) {
        switch self {
        case .queue(let queue):
            queue.async(execute: work)
        default:
            fatalError("can not execute async work in current queue")
        }
    }
    
    func sync<T>(execute work: () throws -> T) rethrows -> T {
        switch self {
        case .queue(let queue):
            if DispatchQueue.currentLabel == queue.label {
                return try work()
            } else {
                return try queue.sync(execute: work)
            }
        case .current:
            return try work()
        }
    }
}


// MARK: - helpers
internal extension DispatchQueue {
    var queue: Queue {
        .queue(self)
    }
}

fileprivate extension DispatchQueue {
    static var currentLabel: String {
        String(validatingUTF8: __dispatch_queue_get_label(nil)) ?? ""
    }
}
