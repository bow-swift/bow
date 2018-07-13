import Foundation

public extension Try {
    public static func traversal() -> Traversal<TryOf<A>, A> {
        return TryTraversal<A>()
    }
    
    public static func each() -> TryEach<A> {
        return TryEach<A>()
    }
}

fileprivate class TryTraversal<A> : Traversal<TryOf<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: TryOf<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, TryOf<A>> where Appl : Applicative, F == Appl.F {
        return s.fix().traverse(f, applicative)
    }
}

public class TryEach<E> : Each {
    public typealias S = TryOf<E>
    public typealias A = E
    
    public func each() -> Traversal<TryOf<E>, E> {
        return Try.traversal()
    }
}
