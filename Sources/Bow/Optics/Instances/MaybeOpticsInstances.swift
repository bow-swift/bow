import Foundation

public extension Maybe {
    public static func traversal() -> Traversal<MaybeOf<A>, A> {
        return MaybeTraversal<A>()
    }
    
    public static func each() -> MaybeEach<A> {
        return MaybeEach<A>()
    }
}

fileprivate class MaybeTraversal<A> : Traversal<MaybeOf<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: MaybeOf<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, MaybeOf<A>> where Appl : Applicative, F == Appl.F {
        return s.fix().traverse(f, applicative)
    }
}

public class MaybeEach<E> : Each {
    public typealias S = MaybeOf<E>
    public typealias A = E
    
    public func each() -> Traversal<MaybeOf<E>, E> {
        return Maybe<E>.traversal()
    }
}
