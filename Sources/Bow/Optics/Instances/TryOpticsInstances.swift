import Foundation

public extension Try {
    public static func traversal() -> Traversal<Try<A>, A> {
        return TryTraversal<A>()
    }
    
    public static func each() -> TryEach<A> {
        return TryEach<A>()
    }
}

fileprivate class TryTraversal<A> : Traversal<Try<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: Try<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, Try<A>> where Appl : Applicative, F == Appl.F {
        return s.traverse(f, applicative)
    }
}

public class TryEach<E> : Each {
    public typealias S = Try<E>
    public typealias A = E
    
    public func each() -> Traversal<Try<E>, E> {
        return Try.traversal()
    }
}
