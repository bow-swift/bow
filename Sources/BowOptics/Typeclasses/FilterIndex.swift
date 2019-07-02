import Bow

/// `FilterIndex` provides a `Traversal` for this structure with all its foci `FilterIndexFoci` whose index `FilterIndexType` satisfies a predicate.
public protocol FilterIndex {
    associatedtype FilterIndexType
    associatedtype FilterIndexFoci

    /// Filters the foci of a `Traversal` with a predicate.
    ///
    /// - Parameter predicate: A predicate to filter the indices of this structure.
    /// - Returns: A `Traversal` between this structure and its foci whose indices match the provided predicate.
    static func filter(_ predicate: @escaping (FilterIndexType) -> Bool) -> Traversal<Self, FilterIndexFoci>
}

// MARK: Related functions
public extension FilterIndex {
    /// Pre-composes the `Traversal` provided by this `FilterIndex` with an isomorphism.
    ///
    /// - Parameters:
    ///   - predicate: A predicate to filter the indices of this structure.
    ///   - iso: An isomorphism.
    /// - Returns: A `Traversal` over a structure that is isomorphic to this one, and has the same foci.
    static func filter<B>(_ predicate: @escaping (FilterIndexType) -> Bool, iso: Iso<B, Self>) -> Traversal<B, FilterIndexFoci> {
        return iso + filter(predicate)
    }
    
    /// Post-composes the `Traversal` provided by the `FilterIndex` with an isomorphism.
    ///
    /// - Parameters:
    ///   - predicate: A predicate to filter the indices of this structure.
    ///   - iso: An isomorphism.
    /// - Returns: A `Traversal` between this structure and new foci that is isomorphic to the original ones.
    static func filter<B>(_ predicate: @escaping (FilterIndexType) -> Bool, iso: Iso<FilterIndexFoci, B>) -> Traversal<Self, B> {
        return filter(predicate) + iso
    }
    
    /// Provides a `Traversal` when this structure has an instance of `Traverse`.
    ///
    /// - Parameters:
    ///   - predicate: A predicate to filter the indices of this structure.
    ///   - zipWithIndex: A function that associates an index to each value inside this structure.`
    /// - Returns: A `Traversal` over the elements of this `Traverse` structure whose indices match the predicate.
    static func filter<F: Traverse, A>(_ predicate: @escaping (FilterIndexType) -> Bool, zipWithIndex: @escaping (Kind<F, A>) -> Kind<F, (A, FilterIndexType)>) -> Traversal<Kind<F, A>, A> where Self: Kind<F, A>, A == FilterIndexFoci {
        return FilterIndexFromTraverseTraversal(zipWithIndex: zipWithIndex, predicate: predicate)
    }
}

private class FilterIndexFromTraverseTraversal<S: Traverse, A, I>: Traversal<Kind<S, A>, A> {
    private let zipWithIndex: (Kind<S, A>) -> Kind<S, (A, I)>
    private let predicate: (I) -> Bool

    init(zipWithIndex: @escaping (Kind<S, A>) -> Kind<S, (A, I)>, predicate: @escaping (I) -> Bool) {
        self.zipWithIndex = zipWithIndex
        self.predicate = predicate
    }

    override func modifyF<F: Applicative>(_ s: Kind<S, A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, Kind<S, A>> {
        return S.traverse(zipWithIndex(s), { x in
            self.predicate(x.1) ? f(x.0): F.pure(x.0)
        })
    }
}
