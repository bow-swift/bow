import Foundation

public extension NonEmptyList {
    public static func traversal() -> Traversal<NonEmptyList<A>, A> {
        return NelTraversal<A>()
    }
    
    public static func each() -> NonEmptyListEach<A> {
        return NonEmptyListEach<A>()
    }
    
    public static func filterIndex() -> NonEmptyListFilterIndex<A> {
        return NonEmptyListFilterIndex<A>()
    }
    
    public static func index() -> NonEmptyListIndex<A> {
        return NonEmptyListIndex<A>()
    }
}

fileprivate class NelTraversal<A> : Traversal<Nel<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: NonEmptyList<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, NonEmptyList<A>> where Appl : Applicative, F == Appl.F {
        return applicative.map(s.traverse(f, applicative), NonEmptyList.fix)
    }
}

public class NonEmptyListEach<E> : Each {
    public typealias S = Nel<E>
    public typealias A = E
    
    public func each() -> Traversal<NonEmptyList<E>, E> {
        return NonEmptyList.traversal()
    }
}

public class NonEmptyListFilterIndex<E> : FilterIndex {
    public typealias S = Nel<E>
    public typealias I = Int
    public typealias A = E
    
    public func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<NonEmptyList<E>, E> {
        return NonEmptyListFilterIndexTraversal<E>(predicate: predicate)
    }
}

fileprivate class NonEmptyListFilterIndexTraversal<E> : Traversal<Nel<E>, E> {
    private let predicate : (Int) -> Bool
    
    init(predicate : @escaping (Int) -> Bool) {
        self.predicate = predicate
    }
    
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: NonEmptyList<E>, _ f: @escaping (E) -> Kind<F, E>) -> Kind<F, NonEmptyList<E>> where Appl : Applicative, F == Appl.F {
        return applicative.map(
            NonEmptyList.fromArrayUnsafe(s.all().enumerated().map(id))
                .traverse({ x in
                    self.predicate(x.offset) ? f(x.element) : applicative.pure(x.element)
                }, applicative), NonEmptyList.fix)
    }
}

public class NonEmptyListIndex<E> : Index {
    public typealias S = Nel<E>
    public typealias I = Int
    public typealias A = E
    
    public func index(_ i: Int) -> Optional<NonEmptyList<E>, E> {
        return Optional<Nel<E>, E>(
            set: { list, e in NonEmptyList.fromArrayUnsafe(
                list.all().enumerated().map { x in
                    (x.offset == i) ? x.element : e
                })
        }, getOrModify: { list in list.getOrNone(i).fold({ Either<Nel<E>, E>.left(list) },
                                                          Either<Nel<E>, E>.right) })
    }
}
