import Foundation
import Bow

// MARK: Optics extensions
public extension ArrayK {
    /// Provides an Iso to go from/to this type to its `Kind` version.
    static var fixIso: Iso<ArrayK<A>, ArrayKOf<A>> {
        return Iso(get: id, reverseGet: ArrayK.fix)
    }
    
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<ArrayK<A>, A> {
        return fixIso + foldK
    }
    
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<ArrayK<A>, A> {
        return fixIso + traversalK
    }
}

// MARK: Instance of `Each` for `ArrayK`
extension ArrayK: Each {
    public typealias EachFoci = A
    
    public static var each: Traversal<ArrayK<A>, A> {
        return traversal
    }
}

// MARK: Instance of `Index` for `ArrayK`
extension ArrayK: Index {
    public typealias IndexType = Int
    public typealias IndexFoci = A
    
    public static func index(_ i: Int) -> Optional<ArrayK<A>, A> {
        return Optional(
            set: { arrayK, e in arrayK.asArray.enumerated().map { x in (x.offset == i) ? e : x.element }.k()
        }, getOrModify: { array in
            array.getOrNone(i).fold({ Either.left(array) }, Either.right)
        })
    }
}

// MARK: Instance of `FilterIndex` for `ArrayK`
extension ArrayK: FilterIndex {
    public typealias FilterIndexType = Int
    public typealias FilterIndexFoci = A
    
    public static func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<ArrayK<A>, A> {
        return ArrayKFilterIndexTraversal(predicate: predicate)
    }
}

// MARK: Instance of `Cons` for `ArrayK`
extension ArrayK: Cons {
    public typealias First = A
    
    public static var cons: Prism<ArrayK<A>, (A, ArrayK<A>)> {
        return Prism(
            getOrModify: { array in array.firstOrNone().fold(
                { .left(array) },
                { head in .right((head, array.dropFirst())) }) },
            reverseGet: { x in x.0 + x.1 })
    }
}

// MARK: Instance of `Snoc` for `ArrayK`
extension ArrayK: Snoc {
    public typealias Last = A
    
    public static var snoc: Prism<ArrayK<A>, (ArrayK<A>, A)> {
        return Prism(
            getOrModify: { array in array.lastOrNone().fold(
                { .left(array) },
                { last in .right((array.dropLast(), last)) }) },
            reverseGet: { x in x.0 + x.1 })
    }
}

private class ArrayKFilterIndexTraversal<A>: Traversal<ArrayK<A>, A> {
    private let predicate: (Int) -> Bool
    
    init(predicate: @escaping (Int) -> Bool) {
        self.predicate = predicate
    }
    
    override func modifyF<F: Applicative>(_ s: ArrayK<A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, ArrayK<A>> {
        return F.map(s.asArray.enumerated().map(id).k().traverse({ x in
            self.predicate(x.offset) ? f(x.element) : F.pure(x.element)
        }), ArrayK<A>.fix)
    }
}
