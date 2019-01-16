import Foundation
import Bow

public extension ArrayK {
    public static func traversal() -> Traversal<ArrayK<A>, A> {
        return ArrayKTraversal<A>()
    }
    
    public static func each() -> ArrayKEach<A> {
        return ArrayKEach<A>()
    }
    
    public static func index() -> ArrayKIndex<A> {
        return ArrayKIndex<A>()
    }
    
    public static func filterIndex() -> ArrayKFilterIndex<A> {
        return ArrayKFilterIndex<A>()
    }
}

fileprivate class ArrayKTraversal<A> : Traversal<ArrayK<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: ArrayK<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, ArrayK<A>> where Appl : Applicative, F == Appl.F {
        return applicative.map(s.traverse(f, applicative), { x in ArrayK.fix(x) })
    }
}

public class ArrayKEach<E> : Each {
    public typealias S = ArrayK<E>
    public typealias A = E
    
    public func each() -> Traversal<ArrayK<E>, E> {
        return ArrayK.traversal()
    }
}

public class ArrayKIndex<E> : Index {
    public typealias S = ArrayK<E>
    public typealias I = Int
    public typealias A = E
    
    public func index(_ i: Int) -> Optional<ArrayK<E>, E> {
        return Optional<ArrayK<E>, E>(
            set: { arrayK, e in
                arrayK.asArray.enumerated().map { x in
                    return (x.offset == i) ? e : x.element
                }.k()
        }, getOrModify: { array in
                array.getOrNone(i).fold({ Either<ArrayK<E>, E>.left(array) }, Either<ArrayK<E>, E>.right)
        })
    }
}

public class ArrayKFilterIndex<E> : FilterIndex {
    public typealias S = ArrayK<E>
    public typealias I = Int
    public typealias A = E
    
    public func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<ArrayK<E>, E> {
        return ArrayKFilterIndexTraversal<E>(predicate: predicate)
    }
}

fileprivate class ArrayKFilterIndexTraversal<A> : Traversal<ArrayK<A>, A> {
    private let predicate : (Int) -> Bool
    
    init(predicate : @escaping (Int) -> Bool) {
        self.predicate = predicate
    }
    
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: ArrayK<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, ArrayK<A>> where Appl : Applicative, F == Appl.F {
        return applicative.map(s.asArray.enumerated().map(id).k().traverse({ x in
            self.predicate(x.offset) ? f(x.element) : applicative.pure(x.element)
        }, applicative), { l in l.fix() })
    }
}
