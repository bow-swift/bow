import Foundation
import Bow

public extension Option {
    public static func traversal() -> Traversal<OptionOf<A>, A> {
        return OptionTraversal<A>()
    }
    
    public static func each() -> OptionEach<A> {
        return OptionEach<A>()
    }
}

fileprivate class OptionTraversal<A> : Traversal<OptionOf<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: OptionOf<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, OptionOf<A>> where Appl : Applicative, F == Appl.F {
        return s.fix().traverse(f, applicative)
    }
}

public class OptionEach<E> : Each {
    public typealias S = OptionOf<E>
    public typealias A = E
    
    public func each() -> Traversal<OptionOf<E>, E> {
        return Option<E>.traversal()
    }
}
