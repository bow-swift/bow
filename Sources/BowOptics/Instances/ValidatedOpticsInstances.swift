import Bow

// MARK: Optics extensions
public extension Validated {
    /// Provides an Iso to go from/to this type to its `Kind` version.
    static var fixIso: Iso<Validated<E, A>, ValidatedOf<E, A>> {
        return Iso(get: id, reverseGet: Validated.fix)
    }
    
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<Validated<E, A>, A> {
        return fixIso + foldK
    }
    
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<Validated<E, A>, A> {
        return fixIso + traversalK
    }
}

// MARK: Instance of `Each` for `Validated`
extension Validated: Each {
    public typealias EachFoci = A
    
    public static var each: Traversal<Validated<E, A>, A> {
        return traversal
    }
}
