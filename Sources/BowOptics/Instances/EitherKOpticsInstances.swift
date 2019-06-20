import Bow

// MARK: Optics extensions
public extension EitherK {
    static var fixIso: Iso<EitherK<F, G, A>, EitherKOf<F, G, A>> {
        return Iso(get: id, reverseGet: EitherK.fix)
    }
}

public extension EitherK where F: Foldable, G: Foldable {
    static var fold: Fold<EitherK<F, G, A>, A> {
        return fixIso + foldK
    }
}

public extension EitherK where F: Traverse, G: Traverse {
    static var traversal: Traversal<EitherK<F, G, A>, A> {
        return fixIso + traversalK
    }
}
