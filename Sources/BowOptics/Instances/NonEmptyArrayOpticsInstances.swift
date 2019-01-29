import Foundation
import Bow

public extension NonEmptyArray {
    public static func traversal() -> Traversal<NonEmptyArray<A>, A> {
        return NEATraversal<A>()
    }
    
    public static func each() -> EachInstance<A> {
        return EachInstance<A>()
    }
    
    public static func filterIndex() -> FilterIndexInstance<A> {
        return FilterIndexInstance<A>()
    }
    
    public static func index() -> IndexInstance<A> {
        return IndexInstance<A>()
    }
    
    public class EachInstance<E> : Each {
        public typealias S = NEA<E>
        public typealias A = E
        
        public func each() -> Traversal<NonEmptyArray<E>, E> {
            return NonEmptyArray<E>.traversal()
        }
    }
    
    public class FilterIndexInstance<E> : FilterIndex {
        public typealias S = NEA<E>
        public typealias I = Int
        public typealias A = E
        
        public func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<NonEmptyArray<E>, E> {
            return NonEmptyArrayFilterIndexTraversal<E>(predicate: predicate)
        }
    }
    
    public class IndexInstance<E> : Index {
        public typealias S = NEA<E>
        public typealias I = Int
        public typealias A = E
        
        public func index(_ i: Int) -> Optional<NonEmptyArray<E>, E> {
            return Optional<NEA<E>, E>(
                set: { nea, e in NonEmptyArray<E>.fromArrayUnsafe(
                    nea.all().enumerated().map { x in
                        (x.offset == i) ? x.element : e
                })
            }, getOrModify: { nea in nea.getOrNone(i).fold({ Either<NEA<E>, E>.left(nea) },
                                                           Either<NEA<E>, E>.right) })
        }
    }
}

fileprivate class NEATraversal<A> : Traversal<NEA<A>, A> {
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: NonEmptyArray<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, NonEmptyArray<A>> where Appl : Applicative, F == Appl.F {
        return applicative.map(s.traverse(f, applicative), NonEmptyArray.fix)
    }
}

fileprivate class NonEmptyArrayFilterIndexTraversal<E> : Traversal<NEA<E>, E> {
    private let predicate : (Int) -> Bool
    
    init(predicate : @escaping (Int) -> Bool) {
        self.predicate = predicate
    }
    
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: NonEmptyArray<E>, _ f: @escaping (E) -> Kind<F, E>) -> Kind<F, NonEmptyArray<E>> where Appl : Applicative, F == Appl.F {
        return applicative.map(
            NonEmptyArray.fromArrayUnsafe(s.all().enumerated().map(id))
                .traverse({ x in
                    self.predicate(x.offset) ? f(x.element) : applicative.pure(x.element)
                }, applicative), NonEmptyArray.fix)
    }
}
