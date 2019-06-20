import Bow

// MARK: Optics extensions
public extension Ior {
    static var fixIso: Iso<Ior<A, B>, IorOf<A, B>> {
        return Iso(get: id, reverseGet: Ior.fix)
    }
    
    static var fold: Fold<Ior<A, B>, B> {
        return fixIso + foldK
    }
    
    static var traversal: Traversal<Ior<A, B>, B> {
        return fixIso + traversalK
    }
}
