/// `Each` provides a `Traversal` that can focus into this structure to see all its foci of type `EachFoci`.
public protocol Each {
    associatedtype EachFoci

    /// Provides a `Traversal` for this structure with focus on `EachFoci`.
    static var each: Traversal<Self, EachFoci> { get }
}

// MARK: Related functions
public extension Each {
    /// Pre-composes the provided `Traversal` from this `Each` with an isomorphism.
    ///
    /// - Parameter iso: An isomorphism.
    /// - Returns: A `Traversal` on a structure that is isomorphic to this structure and has the same foci.
    static func each<B>(_ iso: Iso<B, Self>) -> Traversal<B, EachFoci> {
        return iso + each
    }
    
    /// Post-composes the provided `Traversal` from this `Each` with an isomorphism.
    ///
    /// - Parameter iso: An isomorphism.
    /// - Returns: A `Traversal` on this structure with a new foci that is isomorphic to the original one.
    static func each<B>(_ iso: Iso<EachFoci, B>) -> Traversal<Self, B> {
        return each + iso
    }
}
