import Foundation

public protocol Comonad: Functor {
    static func coflatMap<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (Kind<Self, A>) -> B) -> Kind<Self, B>
    static func extract<A>(_ fa: Kind<Self, A>) -> A
}

public extension Comonad {
    public static func duplicate<A>(_ fa: Kind<Self, A>) -> Kind<Self, Kind<Self, A>> {
        return coflatMap(fa, id)
    }
}

// MARK: Syntax for Comonad

public extension Kind where F: Comonad {
    public func coflatMap<B>(_ f: @escaping (Kind<F, A>) -> B) -> Kind<F, B> {
        return F.coflatMap(self, f)
    }

    public func extract() -> A {
        return F.extract(self)
    }

    public func duplicate() -> Kind<F, Kind<F, A>> {
        return F.duplicate(self)
    }
}
