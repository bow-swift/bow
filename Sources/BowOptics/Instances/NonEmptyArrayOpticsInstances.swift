import Foundation
import Bow

// MARK: Optics extensions
public extension NonEmptyArray {
    /// Provides an Iso to go from/to this type to its `Kind` version.
    static var fixIso: Iso<NEA<A>, NonEmptyArrayOf<A>> {
        return Iso(get: id, reverseGet: NEA.fix)
    }
    
    /// Provides a Fold based on the Foldable instance of this type.
    static var fold: Fold<NEA<A>, A> {
        return fixIso + foldK
    }
    
    /// Provides a Traversal based on the Traverse instance of this type.
    static var traversal: Traversal<NEA<A>, A> {
        return fixIso + traversalK
    }
}

// MARK: Instance of `Each` for `NonEmptyArray`
extension NonEmptyArray: Each {
    public typealias EachFoci = A
    
    public static var each: Traversal<NonEmptyArray<A>, A> {
        return traversal
    }
}

// MARK: Instance of `Index` for `NonEmptyArray`
extension NonEmptyArray: Index {
    public typealias IndexType = Int
    public typealias IndexFoci = A
    
    public static func index(_ i: Int) -> Optional<NonEmptyArray<A>, A> {
        return Optional(
            set: { nea, e in NEA.fromArrayUnsafe(nea.all().enumerated().map { x in (x.offset == i) ? x.element : e })},
            getOrModify: { nea in nea.getOrNone(i).fold({ Either.left(nea) }, Either.right) })
    }
}

// MARK: Instance of `FilterIndex` for `NonEmptyArray`
extension NonEmptyArray: FilterIndex {
    public typealias FilterIndexType = Int
    public typealias FilterIndexFoci = A
    
    public static func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<NonEmptyArray<A>, A> {
        return NonEmptyArrayFilterIndexTraversal(predicate: predicate)
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
