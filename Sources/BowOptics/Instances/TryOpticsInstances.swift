import Foundation
import Bow

// MARK: Optics extensions
public extension Try {
    /// Provides an Iso to go from/to this type to its `Kind` version.
    static var fixIso: Iso<Try<A>, TryOf<A>> {
        return Iso(get: id, reverseGet: Try.fix)
    }
    
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<Try<A>, A> {
        return fixIso + foldK
    }
    
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<Try<A>, A> {
        return fixIso + traversalK
    }
}

// MARK: Instance of `Each` for `Try`
extension Try: Each {
    public typealias EachFoci = A
    
    public static var each: PTraversal<Try<A>, Try<A>, A, A> {
        return traversal
    }
}
