import Bow

// MARK: Optics extensions
public extension Const {
    /// Provides an Iso to go from/to this type to its `Kind` version.
    static var fixIso: Iso<Const<A, T>, ConstOf<A, T>> {
        return Iso(get: id, reverseGet: Const.fix)
    }
    
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<Const<A, T>, T> {
        return fixIso + foldK
    }
    
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<Const<A, T>, T> {
        return fixIso + traversalK
    }
}

// MARK: Instance of `Each` for `Const`
extension Const: Each {
    public typealias EachFoci = T
    
    public static var each: Traversal<Const<A, T>, T> {
        return traversal
    }
}
