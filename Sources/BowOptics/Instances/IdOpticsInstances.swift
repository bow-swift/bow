import Bow

// MARK: Optics extensions
public extension Id {
    static var fixIso: Iso<Id<A>, IdOf<A>> {
        return Iso(get: id, reverseGet: Id.fix)
    }
    
    static var fold: Fold<Id<A>, A> {
        return fixIso + foldK
    }
    
    static var traversal: Traversal<Id<A>, A> {
        return fixIso + traversalK
    }
}
