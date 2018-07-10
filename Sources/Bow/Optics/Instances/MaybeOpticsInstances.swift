import Foundation

public extension Maybe {
    public static func traversal() -> Traversal<Maybe<A>, A> {
        return MaybeTraversal<A>()
    }
    
    public static func each() -> MaybeEach<A> {
        return MaybeEach<A>()
    }
}

fileprivate class MaybeTraversal<A> : Traversal<Maybe<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: Maybe<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, Maybe<A>> where Appl : Applicative, F == Appl.F {
        return s.traverse(f, applicative)
    }
}

public class MaybeEach<E> : Each {
    public typealias S = Maybe<E>
    public typealias A = E
    
    public func each() -> Traversal<Maybe<E>, E> {
        return Maybe<E>.traversal()
    }
}
