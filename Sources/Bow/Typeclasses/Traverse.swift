import Foundation

/// Traverse provides a type with the ability to traverse a structure with an effect.
public protocol Traverse: Functor, Foldable {
    /// Maps each element of a structure to an effect, evaluates them from left to right and collects the results.
    ///
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    static func traverse<G: Applicative, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<Self, B>>
}

public extension Traverse {
    /// Evaluate each effect in a structure of values and collects the results.
    ///
    /// - Parameter fga: A structure of values.
    /// - Returns: Results collected under the context of the effects.
    static func sequence<G: Applicative, A>(_ fga: Kind<Self, Kind<G, A>>) -> Kind<G, Kind<Self, A>> {
        return traverse(fga, id)
    }
}

public extension Traverse where Self: Monad {
    /// A traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - fa: A structure of values.
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    static func flatTraverse<G: Applicative, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, Kind<Self, B>>) -> Kind<G, Kind<Self, B>> {
        return G.map(traverse(fa, f), Self.flatten)
    }
}

// MARK: Syntax for Traverse

public extension Kind where F: Traverse {
    /// Maps each element of this structure to an effect, evaluates them from left to right and collects the results.
    ///
    /// - Parameters:
    ///   - f: A function producing an effect.
    /// - Returns: Results collected under the context of the effect provided by the function.
    func traverse<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<F, B>> {
        return F.traverse(self, f)
    }

    /// Evaluate each effect in this structure of values and collects the results.
    ///
    /// - Returns: Results collected under the context of the effects.
    func sequence<G: Applicative, AA>() -> Kind<G, Kind<F, AA>> where A == Kind<G, AA>{
        return F.sequence(self)
    }
}

public extension Kind where F: Traverse & Monad {
    /// A traverse followed by flattening the inner result.
    ///
    /// - Parameters:
    ///   - f: A transforming function yielding nested effects.
    /// - Returns: Results collected and flattened under the context of the effects.
    func flatTraverse<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, Kind<F, B>>) -> Kind<G, Kind<F, B>> {
        return F.flatTraverse(self, f)
    }
}
