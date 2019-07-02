/// `Index` provides an `Optional` for this structure to focus on an optional `IndexFoci` at a given index `IndexType`.
public protocol Index {
    associatedtype IndexType
    associatedtype IndexFoci

    /// Provides an `Optional` that focuses on a value at a given index.
    ///
    /// - Parameter i: Index to focus on.
    /// - Returns: An `Optional` optic that focuses on a value of this structure.
    static func index(_ i: IndexType) -> Optional<Self, IndexFoci>
}

// MARK: Related functions
public extension Index {
    /// Pre-composes the `Optional` provided by this `Index` with an isomorphism.
    ///
    /// - Parameters:
    ///   - i: Index to focus this structure.
    ///   - iso: An isomorphism.
    /// - Returns: An `Optional` optic between a structure that is isomorphic to this one and the same foci, focused at the provided index.
    static func index<B>(_ i: IndexType, iso: Iso<B, Self>) -> Optional<B, IndexFoci> {
        return iso + index(i)
    }
    
    /// Post-composes the `Optional` provided by this `Index` with an isomorphism.
    ///
    /// - Parameters:
    ///   - i: Index to focus this structure.
    ///   - iso: An isomorphism.
    /// - Returns: An `Optional` between this optic and new foci isomorphic to the original one, focused at the provided index.
    static func index<B>(_ i: IndexType, iso: Iso<IndexFoci, B>) -> Optional<Self, B> {
        return index(i) + iso
    }
}
