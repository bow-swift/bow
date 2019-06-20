import Bow

// MARK: Optics extensions
public extension Const {
    static var fixIso: Iso<Const<A, T>, ConstOf<A, T>> {
        return Iso(get: id, reverseGet: Const.fix)
    }
    
    static var traversal: Traversal<Const<A, T>, T> {
        return fixIso + traversalK
    }
}
