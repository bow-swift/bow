import Foundation

public protocol Index : Typeclass {
    associatedtype S
    associatedtype I
    associatedtype A
    
    func index(_ i : I) -> Optional<S, A>
}
