import Foundation

public protocol Functor: Invariant {
    static func map<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B) -> Kind<Self, B>
}

public extension Functor {
    public static func imap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (B) -> A) -> Kind<Self, B> {
        return map(fa, f)
    }

    public static func lift<A, B>(_ f : @escaping (A) -> B) -> (Kind<Self, A>) -> Kind<Self, B> {
        return { fa in map(fa, f) }
    }

    public static func void<A>(_ fa : Kind<Self, A>) -> Kind<Self, ()> {
        return map(fa, {_ in })
    }

    public static func fproduct<A, B>(_ fa : Kind<Self, A>, _ f : @escaping (A) -> B) -> Kind<Self, (A, B)> {
        return map(fa, { a in (a, f(a)) })
    }

    public static func `as`<A, B>(_ fa : Kind<Self, A>, _ b : B) -> Kind<Self, B> {
        return map(fa, { _ in b })
    }

    public static func tupleLeft<A, B>(_ fa : Kind<Self, A>, _ b : B) -> Kind<Self, (B, A)> {
        return map(fa, { a in (b, a) })
    }

    public static func tupleRight<A, B>(_ fa : Kind<Self, A>, _ b : B) -> Kind<Self, (A, B)> {
        return map(fa, { a in (a, b) })
    }
}

// MARK: Syntax for Functor

public extension Kind where F: Functor {
    public func map<B>(_ f : @escaping (A) -> B) -> Kind<F, B> {
        return F.map(self, f)
    }

    public static func lift<A, B>(_ f : @escaping (A) -> B) -> (Kind<F, A>) -> Kind<F, B> {
        return { fa in fa.map(f) }
    }

    public func void() -> Kind<F, ()> {
        return F.void(self)
    }

    public func fproduct<B>(_ f : @escaping (A) -> B) -> Kind<F, (A, B)> {
        return F.fproduct(self, f)
    }

    public func `as`<B>(_ b : B) -> Kind<F, B> {
        return F.as(self, b)
    }

    public func tupleLeft<B>(_ b : B) -> Kind<F, (B, A)> {
        return F.tupleLeft(self, b)
    }

    public func tupleRight<B>(_ b : B) -> Kind<F, (A, B)> {
        return F.tupleRight(self, b)
    }
}
