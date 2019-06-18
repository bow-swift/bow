import Foundation
import Bow

public extension Try {
//    static func traversal() -> Traversal<TryOf<A>, A> {
//        return TryTraversal<A>()
//    }
//    
//    static func each() -> TryEach<A> {
//        return TryEach<A>()
//    }
//    
//    private class TryTraversal<A>: Traversal<TryOf<A>, A> {
//        override func modifyF<F: Applicative>(_ s: Kind<ForTry, A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, Kind<ForTry, A>> {
//            return s.traverse(f)
//        }
//    }
//    
//    class TryEach<E> : Each {
//        public typealias S = TryOf<E>
//        public typealias A = E
//        
//        public func each() -> Traversal<TryOf<E>, E> {
//            return Try<E>.traversal()
//        }
//    }
}
