import Foundation
import Bow

public extension Try {
    public static func traversal() -> Traversal<TryOf<A>, A> {
        return TryTraversal<A>()
    }
    
    public static func each() -> TryEach<A> {
        return TryEach<A>()
    }
    
    fileprivate class TryTraversal<A>: Traversal<TryOf<A>, A> {
        override func modifyF<F: Applicative>(_ s: Kind<ForTry, A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, Kind<ForTry, A>> {
            return s.traverse(f)
        }
    }
    
    public class TryEach<E> : Each {
        public typealias S = TryOf<E>
        public typealias A = E
        
        public func each() -> Traversal<TryOf<E>, E> {
            return Try<E>.traversal()
        }
    }
}
