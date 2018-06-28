import Foundation

public protocol FilterIndex {
    associatedtype S
    associatedtype I
    associatedtype A
    
    func filter(_ predicate : (I) -> Bool) -> Traversal<S, A>
}
