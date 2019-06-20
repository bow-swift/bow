import Foundation
import Bow

// MARK: Optics extensions
public extension Option {
    static var fixIso: Iso<Option<A>, OptionOf<A>> {
        return Iso(get: id, reverseGet: Option.fix)
    }
    
    static var fold: Fold<Option<A>, A> {
        return fixIso + foldK
    }
    
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
