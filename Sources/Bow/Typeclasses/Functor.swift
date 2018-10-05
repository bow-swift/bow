import Foundation

public protocol Functor : Invariant {
    func map<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> B) -> Kind<F, B>
}

public extension Functor {
    public func imap<A, B>(_ fa: Kind<F, A>, _ f: @escaping (A) -> B, _ g: @escaping (B) -> A) -> Kind<F, B> {
        return self.map(fa, f)
    }
    
    public func lift<A, B>(_ f : @escaping (A) -> B) -> (Kind<F, A>) -> Kind<F, B> {
        return { fa in self.map(fa, f) }
    }
    
    public func void<A>(_ fa : Kind<F, A>) -> Kind<F, ()> {
        return self.map(fa, {_ in })
    }
    
    public func fproduct<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> B) -> Kind<F, (A, B)> {
        return self.map(fa, { a in (a, f(a)) })
    }
    
    public func `as`<A, B>(_ fa : Kind<F, A>, _ b : B) -> Kind<F, B> {
        return self.map(fa, { _ in b })
    }
    
    public func tupleLeft<A, B>(_ fa : Kind<F, A>, _ b : B) -> Kind<F, (B, A)> {
        return self.map(fa, { a in (b, a) })
    }
    
    public func tupleRight<A, B>(_ fa : Kind<F, A>, _ b : B) -> Kind<F, (A, B)> {
        return self.map(fa, { a in (a, b) })
    }
}

