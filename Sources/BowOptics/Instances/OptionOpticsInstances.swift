import Foundation
import Bow

public extension Option {
    public static func traversal() -> Traversal<OptionOf<A>, A> {
        return OptionTraversal<A>()
    }
    
    public static func each() -> EachInstance<A> {
        return EachInstance<A>()
    }
    
    fileprivate class OptionTraversal<A> : Traversal<OptionOf<A>, A> {
        override func modifyF<F: Applicative>(_ s: OptionOf<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, OptionOf<A>> {
            return s.traverse(f)
        }
    }
    
    public class EachInstance<E> : Each {
        public typealias S = OptionOf<E>
        public typealias A = E
        
        public func each() -> Traversal<OptionOf<E>, E> {
            return Option<E>.traversal()
        }
    }
}

