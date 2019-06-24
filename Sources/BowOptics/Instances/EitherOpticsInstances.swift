import Foundation
import Bow

// MARK: Optics extensions
public extension Either {
    /// Provides an Iso to go from/to this type to its `Kind` version.
    static var fixIso: Iso<Either<A, B>, EitherOf<A, B>> {
        return Iso(get: id, reverseGet: Either.fix)
    }
    
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<Either<A, B>, B> {
        return fixIso + foldK
    }
    
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<Either<A, B>, B> {
        return fixIso + traversalK
    }
}

// MARK: Instance of `Each` for `Either`
extension Either: Each {
    public typealias EachFoci = B
    
    public static var each: Traversal<Either<A, B>, B> {
        return traversal
    }
}
