import Bow

// MARK: Optics extensions
public extension Kind where F: Traverse {
    static var traversalK: Traversal<Kind<F, A>, A> {
        return KindTraversal<F, A>()
    }
}

private class KindTraversal<G: Traverse, A>: Traversal<Kind<G, A>, A> {
    override func modifyF<F: Applicative>(_ s: Kind<G, A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, Kind<G, A>> {
        return s.traverse(f)
    }
}
