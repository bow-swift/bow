import Foundation

public protocol Invariant : Typeclass {
    associatedtype F
    
    func imap<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> B, _ g : @escaping (B) -> A) -> Kind<F, B>
}

public protocol Invariant2: Typeclass {
    static func imap<A, B>(_ fa : Kind<Self, A>, _ f : @escaping (A) -> B, _ g : @escaping (B) -> A) -> Kind<Self, B>
}

public extension Kind where F: Invariant2 {
    func imap<B>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> A) -> Kind<F, B> {
        return F.imap(self, f, g)
    }
}
