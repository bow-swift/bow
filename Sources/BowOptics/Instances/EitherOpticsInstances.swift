import Foundation
import Bow

public extension Either {
    public static func traversal() -> Traversal<Either<A, B>, B> {
        return EitherTraversal<A, B>()
    }
    
    public static func each() -> EachInstance<A, B> {
        return EachInstance<A, B>()
    }
    
    fileprivate class EitherTraversal<L, R> : Traversal<Either<L, R>, R> {
        override func modifyF<Appl, F>(_ applicative: Appl, _ s: Either<L, R>, _ f: @escaping (R) -> Kind<F, R>) -> Kind<F, Either<L, R>> where Appl : Applicative, F == Appl.F {
            return applicative.map(s.traverse(f, applicative), { x in Either<L, R>.fix(x) })
        }
    }
    
    public class EachInstance<L, R> : Each {
        public typealias S = Either<L, R>
        public typealias A = R
        
        public func each() -> Traversal<Either<L, R>, R> {
            return Either<L, R>.traversal()
        }
    }
}

