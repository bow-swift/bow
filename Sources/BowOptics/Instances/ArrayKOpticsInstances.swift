import Foundation
import Bow

// MARK: Optics extensions
public extension ArrayK {
    static var fixIso: Iso<ArrayK<A>, ArrayKOf<A>> {
        return Iso(get: id, reverseGet: ArrayK.fix)
    }
    
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
