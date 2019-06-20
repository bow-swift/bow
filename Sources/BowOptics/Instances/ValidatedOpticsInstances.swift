import Bow

// MARK: Optics extensions
public extension Validated {
    static var fixIso: Iso<Validated<E, A>, ValidatedOf<E, A>> {
        return Iso(get: id, reverseGet: Validated.fix)
    }
    
    static var fold: Fold<Validated<E, A>, A> {
        return fixIso + foldK
    }
    
    static var traversal: Traversal<Validated<E, A>, A> {
        return fixIso + traversalK
    }
}
