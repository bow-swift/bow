import Foundation

public extension ListK {
    public static func traversal() -> Traversal<ListK<A>, A> {
        return ListKTraversal<A>()
    }
    
    public static func each() -> ListKEach<A> {
        return ListKEach<A>()
    }
    
    public static func index() -> ListKIndex<A> {
        return ListKIndex<A>()
    }
    
    public static func filterIndex() -> ListKFilterIndex<A> {
        return ListKFilterIndex<A>()
    }
}

fileprivate class ListKTraversal<A> : Traversal<ListK<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: ListK<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, ListK<A>> where Appl : Applicative, F == Appl.F {
        return applicative.map(s.traverse(f, applicative), { x in ListK.fix(x) })
    }
}

public class ListKEach<E> : Each {
    public typealias S = ListK<E>
    public typealias A = E
    
    public func each() -> Traversal<ListK<E>, E> {
        return ListK.traversal()
    }
}

public class ListKIndex<E> : Index {
    public typealias S = ListK<E>
    public typealias I = Int
    public typealias A = E
    
    public func index(_ i: Int) -> Optional<ListK<E>, E> {
        return Optional<ListK<E>, E>(
            set: { list, e in
                list.asArray.enumerated().map { x in
                    return (x.offset == i) ? e : x.element
                }.k()
        }, getOrModify: { list in
                list.getOrNone(i).fold({ Either<ListK<E>, E>.left(list) }, Either<ListK<E>, E>.right)
        })
    }
}

public class ListKFilterIndex<E> : FilterIndex {
    public typealias S = ListK<E>
    public typealias I = Int
    public typealias A = E
    
    public func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<ListK<E>, E> {
        return ListKFilterIndexTraversal<E>(predicate: predicate)
    }
}

fileprivate class ListKFilterIndexTraversal<A> : Traversal<ListK<A>, A> {
    private let predicate : (Int) -> Bool
    
    init(predicate : @escaping (Int) -> Bool) {
        self.predicate = predicate
    }
    
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: ListK<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, ListK<A>> where Appl : Applicative, F == Appl.F {
        return applicative.map(s.asArray.enumerated().map(id).k().traverse({ x in
            self.predicate(x.offset) ? f(x.element) : applicative.pure(x.element)
        }, applicative), { l in l.fix() })
    }
}
