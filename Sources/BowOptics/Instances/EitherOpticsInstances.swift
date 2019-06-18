import Foundation
import Bow

// MARK: Optics extensions
public extension Either {
    static func traversal() -> Traversal<Either<A, B>, B> {
        return EitherTraversal<A, B>()
    }
}

// MARK: Instance of `Each` for `Either`
extension Either: Each {
    public typealias EachFoci = B
    
    public static var each: Traversal<Either<A, B>, B> {
        return EitherTraversal<A, B>()
    }
}

private class EitherTraversal<L, R>: Traversal<Either<L, R>, R> {
    override func modifyF<F: Applicative>(_ s: Either<L, R>, _ f: @escaping (R) -> Kind<F, R>) -> Kind<F, Either<L, R>> {
        return s.traverse(f).map { x in x^ }
    }
}
