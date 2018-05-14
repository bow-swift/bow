import Foundation

public protocol At : Typeclass {
    associatedtype S
    associatedtype I
    associatedtype A
    
    func at(_ i : I) -> Lens<S, A>
}
