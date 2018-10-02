import Foundation

public protocol Contravariant : Invariant {
    func contramap<A, B>(_ fa : Kind<F, A>, _ f : @escaping (B) -> A) -> Kind<F, B>
}

public extension Contravariant {
    public func imap<A, B>(_ fa: Kind<F, A>, _ f: @escaping (A) -> B, _ g: @escaping (B) -> A) -> Kind<F, B> {
        return self.contramap(fa, g)
    }
    
    public func lift<A, B>(_ f : @escaping (A) -> B) -> (Kind<F, B>) -> Kind<F, A> {
        return { fa in self.contramap(fa, f) }
    }
}
