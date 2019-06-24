import Foundation
import Bow

// MARK: Optics extensions
public extension Option {
    /// Provides an Iso to go from/to this type to its `Kind` version.
    static var fixIso: Iso<Option<A>, OptionOf<A>> {
        return Iso(get: id, reverseGet: Option.fix)
    }
    
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<Option<A>, A> {
        return fixIso + foldK
    }
    
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<Option<A>, A> {
        return fixIso + traversalK
    }
}

// MARK: Instance of `Each` for `Option`
extension Option: Each {
    public typealias EachFoci = A
    
    public static var each: Traversal<Option<A>, A> {
        return traversal
    }
}
