import Bow

// MARK: Optics extensions
public extension Const {
    static var fixIso: Iso<Const<A, T>, ConstOf<A, T>> {
        return Iso(get: id, reverseGet: Const.fix)
    }
    
    static var fold: Fold<Const<A, T>, T> {
        return fixIso + foldK
    }
    
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
