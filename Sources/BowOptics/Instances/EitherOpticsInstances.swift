import Foundation
import Bow

public extension Either {
    static func traversal() -> Traversal<Either<A, B>, B> {
        return EitherTraversal<A, B>()
    }
    
    static func each() -> EachInstance<A, B> {
        return EachInstance<A, B>()
    }
    
    private class EitherTraversal<L, R> : Traversal<Either<L, R>, R> {
        override func modifyF<F: Applicative>(_ s: Either<L, R>, _ f: @escaping (R) -> Kind<F, R>) -> Kind<F, Either<L, R>> {
            return F.map(s.traverse(f), { x in Either<L, R>.fix(x) })
        }
    }
    
    class EachInstance<L, R> : Each {
        public typealias S = Either<L, R>
        public typealias A = R
        
        public func each() -> Traversal<Either<L, R>, R> {
            return Either<L, R>.traversal()
        }
    }
}

