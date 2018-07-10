import Foundation

public protocol FilterIndex {
    associatedtype S
    associatedtype I
    associatedtype A
    
    func filter(_ predicate : @escaping (I) -> Bool) -> Traversal<S, A>
}
