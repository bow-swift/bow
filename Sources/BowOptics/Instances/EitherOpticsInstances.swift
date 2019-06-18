import Foundation
import Bow

// MARK: Optics extensions
public extension Either {
    static var fixIso: Iso<Either<A, B>, EitherOf<A, B>> {
        return Iso(get: id, reverseGet: Either.fix)
    }
    
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
