import Foundation

public protocol Each {
    associatedtype S
    associatedtype A
    
    func each() -> Traversal<S, A>
}
