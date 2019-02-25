import Foundation

public protocol Traverse: Functor, Foldable {
    static func traverse<G: Applicative, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<Self, B>>
}

public extension Traverse {
    public static func sequence<G: Applicative, A>(_ fga: Kind<Self, Kind<G, A>>) -> Kind<G, Kind<Self, A>> {
        return traverse(fga, id)
    }
    
    public static func flatTraverse<G: Applicative, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, Kind<Self, B>>) -> Kind<G, Kind<Self, B>> where Self: Monad {
        return G.map(traverse(fa, f), Self.flatten)
    }
}

// MARK: Syntax for Traverse

public extension Kind where F: Traverse {
    public func traverse<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<F, B>> {
        return F.traverse(self, f)
    }

    public static func sequence<G: Applicative>(_ fga: Kind<F, Kind<G, A>>) -> Kind<G, Kind<F, A>> {
        return F.sequence(fga)
    }
}

public extension Kind where F: Traverse & Monad {
    public func flatTraverse<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, Kind<F, B>>) -> Kind<G, Kind<F, B>> {
        return F.flatTraverse(self, f)
    }
}
