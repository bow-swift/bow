import Foundation

/// TraverseFilter represents array-like structures that can be traversed and filtered as a single combined operation. It provides the same capabilities as `Traverse` and `FunctorFilter` together.
public protocol TraverseFilter: Traverse, FunctorFilter {
    /// A combined traverse and filter operation. Filtering is handled using `Option` instead of Bool so that the output can be different than the input type.
    ///
    /// - Parameters:
    ///   - fa: A value in the context implementing this instance.
    ///   - f: A function to traverse and filter each value.
    /// - Returns: Result of traversing this structure and filter values using the provided function.
    static func traverseFilter<A, B, G: Applicative>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, OptionOf<B>>) -> Kind<G, Kind<Self, B>>
}

// MARK: Related functions

public extension TraverseFilter {
    /// Filters values in a different context.
    ///
    /// - Parameters:
    ///   - fa: A value in the context implementing this instance.
    ///   - f: A function to filter each value.
    /// - Returns: Result of traversing this structure and filter values using the provided function.
    static func filterA<A, G: Applicative>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, Bool>) -> Kind<G, Kind<Self, A>> {
        return traverseFilter(fa, { a in G.map(f(a), { b in b ? Option.some(a) : Option.none() }) })
    }

    /// Filters values using a predicate.
    ///
    /// - Parameters:
    ///   - fa: A value in the context implementing this instance.
    ///   - f: A boolean predicate.
    /// - Returns: Result of traversing this structure and filter values using the provided function.
    static func filter<A>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Bool) -> Kind<Self, A> {
        return (filterA(fa, { a in Id.pure(f(a)) })).extract()
    }
}

// MARK: Syntax for TraverseFilter

public extension Kind where F: TraverseFilter {
    /// A combined traverse and filter operation. Filtering is handled using `Option` instead of Bool so that the output can be different than the input type.
    ///
    /// This is a convenience method to call `TraverseFilter.traverseFilter` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - fa: A value in this context.
    ///   - f: A function to traverse and filter each value.
    /// - Returns: Result of traversing this structure and filter values using the provided function.
    func traverseFilter<B, G: Applicative>(_ f: @escaping (A) -> Kind<G, OptionOf<B>>) -> Kind<G, Kind<F, B>> {
        return F.traverseFilter(self, f)
    }

    /// Filters values in a different context.
    ///
    /// This is a convenience method to call `TraverseFilter.filterA` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - fa: A value in this context.
    ///   - f: A function to filter each value.
    /// - Returns: Result of traversing this structure and filter values using the provided function.
    func filterA<G: Applicative>(_ f: @escaping (A) -> Kind<G, Bool>) -> Kind<G, Kind<F, A>> {
        return F.filterA(self, f)
    }
}
