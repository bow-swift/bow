import Foundation
import Bow

public extension ArrayK {
//    static func traversal() -> Traversal<ArrayK<A>, A> {
//        return ArrayKTraversal<A>()
//    }
//
//    static func each() -> EachInstance<A> {
//        return EachInstance<A>()
//    }
//
//    static func index() -> IndexInstance<A> {
//        return IndexInstance<A>()
//    }
//
//    static func filterIndex() -> FilterIndexInstance<A> {
//        return FilterIndexInstance<A>()
//    }
//
//    class EachInstance<E>: Each {
//        public typealias S = ArrayK<E>
//        public typealias A = E
//
//        public func each() -> Traversal<ArrayK<E>, E> {
//            return ArrayK<E>.traversal()
//        }
//    }
//
//    class IndexInstance<E>: Index {
//        public typealias S = ArrayK<E>
//        public typealias I = Int
//        public typealias A = E
//
//        public func index(_ i: Int) -> Optional<ArrayK<E>, E> {
//            return Optional<ArrayK<E>, E>(
//                set: { arrayK, e in
//                    arrayK.asArray.enumerated().map { x in
//                        return (x.offset == i) ? e : x.element
//                        }.k()
//            }, getOrModify: { array in
//                array.getOrNone(i).fold({ Either<ArrayK<E>, E>.left(array) }, Either<ArrayK<E>, E>.right)
//            })
//        }
//    }
//
//    class FilterIndexInstance<E>: FilterIndex {
//        public typealias S = ArrayK<E>
//        public typealias I = Int
//        public typealias A = E
//
//        public func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<ArrayK<E>, E> {
//            return ArrayKFilterIndexTraversal<E>(predicate: predicate)
//        }
//    }
//
//    private class ArrayKFilterIndexTraversal<A>: Traversal<ArrayK<A>, A> {
//        private let predicate: (Int) -> Bool
//
//        init(predicate : @escaping (Int) -> Bool) {
//            self.predicate = predicate
//        }
//
//        override func modifyF<F: Applicative>(_ s: ArrayK<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, ArrayK<A>> {
//            return F.map(s.asArray.enumerated().map(id).k().traverse({ x in
//                self.predicate(x.offset) ? f(x.element) : F.pure(x.element)
//            }), ArrayK<A>.fix)
//        }
//    }
//
//    private class ArrayKTraversal<A>: Traversal<ArrayK<A>, A> {
//        override func modifyF<F: Applicative>(_ s: ArrayK<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, ArrayK<A>>  {
//            return F.map(s.traverse(f), { x in ArrayK<A>.fix(x) })
//        }
//    }
}
