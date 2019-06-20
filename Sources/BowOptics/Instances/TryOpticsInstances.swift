import Foundation
import Bow

// MARK: Optics extensions
public extension Try {
    static var fixIso: Iso<Try<A>, TryOf<A>> {
        return Iso(get: id, reverseGet: Try.fix)
    }
    
    static var fold: Fold<Try<A>, A> {
        return fixIso + foldK
    }
    
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
