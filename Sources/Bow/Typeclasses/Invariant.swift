import Foundation

public protocol Invariant : Typeclass {
    associatedtype F
    
    func imap<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> B, _ g : @escaping (B) -> A) -> Kind<F, B>
}
