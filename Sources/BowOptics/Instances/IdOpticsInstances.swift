import Bow

// MARK: Optics extensions
public extension Id {
    /// Provides an Iso to go from/to this type to its `Kind` version.
    static var fixIso: Iso<Id<A>, IdOf<A>> {
        return Iso(get: id, reverseGet: Id.fix)
    }
    
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<Id<A>, A> {
        return fixIso + foldK
    }
    
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<Id<A>, A> {
        return fixIso + traversalK
    }
}

// MARK: Instance of `Each` for `Id`
extension Id: Each {
    public typealias EachFoci = A
    
    public static var each: Traversal<Id<A>, A> {
        return traversal
    }
}
