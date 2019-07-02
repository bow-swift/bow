import Bow

/// `At` provides a `Lens` for a this structure to focus at `AtFoci` at a given index `AtIndex`.
public protocol At {
    associatedtype AtIndex
    associatedtype AtFoci

    /// Obtains a `Lens` for a structure of this type with focus in `AtFoci` at index `AtIndex`.
    ///
    /// - Parameter i: Index to zoom into this structure and find focus.
    /// - Returns: A `Lens` with focus on `AtFoci` at the given index.
    static func at(_ i: AtIndex) -> Lens<Self, AtFoci>
}

// MARK: Related functions
public extension At {
    /// Deletes a value associated with an index by setting it to `Option.none`
    ///
    /// - Parameter i: Index of the value to remove.
    /// - Returns: A new structure where the element at the given index has been removed.
    func remove<A>(_ i: AtIndex) -> Self where AtFoci == Option<A> {
        return Self.at(i).set(self, .none())
    }
    
    /// Deletes a value associated with an index by setting it to nil.
    ///
    /// - Parameter i: Index of the value to remove.
    /// - Returns: A new structure where the element at the given index has been removed.
    func remove<A>(_ i: AtIndex) -> Self where AtFoci == A? {
        return Self.at(i).set(self, nil)
    }
    
    /// Post-composes the lens at a given index with an isomorphism.
    ///
    /// - Parameters:
    ///   - i: Index for the value to focus on.
    ///   - iso: An isomorphism for post-composition.
    /// - Returns: A Lens that focuses on the provided index, transformed with the provided isomophism.
    static func at<B>(_ i: AtIndex, iso: Iso<AtFoci, B>) -> Lens<Self, B> {
        return Self.at(i) + iso
    }
    
    /// Pre-composes the lens at a given index with an isomorphism.
    ///
    /// - Parameters:
    ///   - i: Index for the value to focus on.
    ///   - iso: An isomorphism for pre-composition.
    /// - Returns: A Lens that focuses on the provided index, where the containing structure has been transformed with the provided isomorphsim.
    static func at<B>(_ i: AtIndex, iso: Iso<B, Self>) -> Lens<B, AtFoci> {
        return iso + Self.at(i)
    }
}
