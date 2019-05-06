import Foundation

/// A FunctorFilter provides the same capabilities as a `Functor`, while filtering out elements simultaneously.
public protocol FunctorFilter: Functor {
    /// Maps the value/s in the context implementing this instance, filtering out the ones resulting in `Option.none`.
    ///
    /// - Parameters:
    ///   - fa: A value in the context implementing this instance.
    ///   - f: A function to map objects and filter them out.
    /// - Returns: Transformed and filtered values, in the context implementing this instance.
    static func mapFilter<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> OptionOf<B>) -> Kind<Self, B>
}

// MARK: Related functions

public extension FunctorFilter {
    /// Removes the `Option.none` value/s in this context and extracts the `Option.some` ones.
    ///
    /// - Parameter fa: Optional values in the context implementing this instance.
    /// - Returns: Plain values in the context implementing this instance.
    static func flattenOption<A>(_ fa: Kind<Self, OptionOf<A>>) -> Kind<Self, A> {
        return mapFilter(fa, id)
    }

    /// Filters out the value/s in the context implementing this instance that do not match the given predicate.
    ///
    /// - Parameters:
    ///   - fa: Value in the context implementing this instance.
    ///   - f: Filtering predicate.
    /// - Returns: Filtered value in the context implementing this instance.
    static func filter<A>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Bool) -> Kind<Self, A> {
        return mapFilter(fa, { a in f(a) ? Option.some(a) : Option.none() })
    }
}

// MARK: Syntax for FunctorFilter

public extension Kind where F: FunctorFilter {
    /// Maps the value/s in the context implementing this instance, filtering out the ones resulting in `Option.none`.
    ///
    /// This is a convenience method to call `FunctorFilter.mapFilter` as an instance method of this type.
    ///
    /// - Parameters:
    ///   - f: A function to map objects and filter them out.
    /// - Returns: Transformed and filtered values, in this context.
    func mapFilter<B>(_ f: @escaping (A) -> OptionOf<B>) -> Kind<F, B> {
        return F.mapFilter(self, f)
    }

    /// Removes the `Option.none` value/s in this context and extracts the `Option.some` ones.
    ///
    /// This is a convenience method to call `FunctorFilter.flattenOption` as a static method of this type.
    ///
    /// - Parameter fa: Optional values in this context.
    /// - Returns: Plain values in this context.
    static func flattenOption(_ fa: Kind<F, OptionOf<A>>) -> Kind<F, A> {
        return F.flattenOption(fa)
    }

    /// Filters out the value/s in this context that do not match the given predicate.
    ///
    /// This is a convenience method to call `FunctorFilter.filter` as a static method of this type.
    ///
    /// - Parameters:
    ///   - f: Filtering predicate.
    /// - Returns: Filtered value in this context.
    func filter(_ f: @escaping (A) -> Bool) -> Kind<F, A> {
        return F.filter(self, f)
    }
}
