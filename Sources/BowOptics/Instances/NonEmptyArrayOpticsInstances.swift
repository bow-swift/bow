import Foundation
import Bow

public extension NonEmptyArray {
    static func traversal() -> Traversal<NonEmptyArray<A>, A> {
        return NEATraversal<A>()
    }

    static func each() -> EachInstance<A> {
        return EachInstance<A>()
    }

    static func filterIndex() -> FilterIndexInstance<A> {
        return FilterIndexInstance<A>()
    }

    static func index() -> IndexInstance<A> {
        return IndexInstance<A>()
    }

    class EachInstance<E>: Each {
        public typealias S = NEA<E>
        public typealias A = E

        public func each() -> Traversal<NonEmptyArray<E>, E> {
            return NonEmptyArray<E>.traversal()
        }
    }

    class FilterIndexInstance<E>: FilterIndex {
        public typealias S = NEA<E>
        public typealias I = Int
        public typealias A = E

        public func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<NonEmptyArray<E>, E> {
            return NonEmptyArrayFilterIndexTraversal<E>(predicate: predicate)
        }
    }

    class IndexInstance<E>: Index {
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

private class NEATraversal<A>: Traversal<NEA<A>, A> {
    override func modifyF<F: Applicative>(_ s: NonEmptyArray<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, NonEmptyArray<A>> {
        return F.map(s.traverse(f), NonEmptyArray.fix)
    }
}

private class NonEmptyArrayFilterIndexTraversal<E>: Traversal<NEA<E>, E> {
    private let predicate: (Int) -> Bool

    init(predicate: @escaping (Int) -> Bool) {
        self.predicate = predicate
    }

    override func modifyF<F: Applicative>(_ s: NonEmptyArray<E>, _ f: @escaping (E) -> Kind<F, E>) -> Kind<F, NonEmptyArray<E>> {
        return F.map(
            NonEmptyArray.fromArrayUnsafe(s.all().enumerated().map(id))
                .traverse({ x in
                    self.predicate(x.offset) ? f(x.element) : F.pure(x.element)
                }), NonEmptyArray.fix)
    }
}
