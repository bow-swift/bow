import Foundation

public protocol Contravariant: Invariant {
    static func contramap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (B) -> A) -> Kind<Self, B>
}

public extension Contravariant {
    public static func imap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (B) -> A) -> Kind<Self, B> {
        return contramap(fa, g)
    }
    
    public static func contralift<A, B>(_ f: @escaping (A) -> B) -> (Kind<Self, B>) -> Kind<Self, A> {
        return { fa in contramap(fa, f) }
    }
}

// MARK: Syntax for Contravariant

public extension Kind where F: Contravariant {
    public func contramap<B>(_ f : @escaping (B) -> A) -> Kind<F, B> {
        return F.contramap(self, f)
    }

    public static func contralift<B>(_ f : @escaping (A) -> B) -> (Kind<F, B>) -> Kind<F, A> {
        return F.contralift(f)
    }
}
