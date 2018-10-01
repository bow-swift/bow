import Foundation

public extension Option {
    public static func traversal() -> Traversal<OptionOf<A>, A> {
        return MaybeTraversal<A>()
    }
    
    public static func each() -> MaybeEach<A> {
        return MaybeEach<A>()
    }
}

fileprivate class MaybeTraversal<A> : Traversal<OptionOf<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: OptionOf<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, OptionOf<A>> where Appl : Applicative, F == Appl.F {
        return s.fix().traverse(f, applicative)
    }
}

public class MaybeEach<E> : Each {
    public typealias S = OptionOf<E>
    public typealias A = E
    
    public func each() -> Traversal<OptionOf<E>, E> {
        return Option<E>.traversal()
    }
}
