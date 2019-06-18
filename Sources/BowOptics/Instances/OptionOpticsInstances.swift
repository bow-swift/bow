import Foundation
import Bow

// MARK: Optics extensions
public extension Option {
    static func traversal() -> Traversal<Option<A>, A> {
        return OptionTraversal<A>()
    }
}

// MARK: Instance of `Each` for `Option`
extension Option: Each {
    public typealias EachFoci = A
    
    public static var each: Traversal<Option<A>, A> {
        return OptionTraversal<A>()
    }
}

private class OptionTraversal<A>: Traversal<Option<A>, A> {
    override func modifyF<F: Applicative>(_ s: Option<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, Option<A>> {
        return s.traverse(f).map { x in x^ }
    }
}
