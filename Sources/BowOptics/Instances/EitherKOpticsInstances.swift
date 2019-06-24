import Bow

// MARK: Optics extensions
public extension EitherK {
    /// Provides an Iso to go from/to this type to its `Kind` version.
    static var fixIso: Iso<EitherK<F, G, A>, EitherKOf<F, G, A>> {
        return Iso(get: id, reverseGet: EitherK.fix)
    }
}

public extension EitherK where F: Foldable, G: Foldable {
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<EitherK<F, G, A>, A> {
        return fixIso + foldK
    }
}

public extension EitherK where F: Traverse, G: Traverse {
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<EitherK<F, G, A>, A> {
        return fixIso + traversalK
    }
}

// MARK: Instance of `Each` for `EitherK`
extension EitherK: Each where F: Traverse, G: Traverse {
    public typealias EachFoci = A
    
    public static var each: Traversal<EitherK<F, G, A>, A> {
        return traversal
    }
}
