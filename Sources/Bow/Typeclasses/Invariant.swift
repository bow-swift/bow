import Foundation

public protocol Invariant {
    static func imap<A, B>(_ fa : Kind<Self, A>, _ f : @escaping (A) -> B, _ g : @escaping (B) -> A) -> Kind<Self, B>
}

// MARK: Syntax for Invariant

public extension Kind where F: Invariant {
    func imap<B>(_ f : @escaping (A) -> B, _ g : @escaping (B) -> A) -> Kind<F, B> {
        return F.imap(self, f, g)
    }
}
