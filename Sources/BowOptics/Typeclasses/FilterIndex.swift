import Foundation
import Bow

public protocol FilterIndex {
    associatedtype FilterIndexType
    associatedtype FilterIndexFoci

    static func filter(_ predicate: @escaping (FilterIndexType) -> Bool) -> Traversal<Self, FilterIndexFoci>
}

public extension FilterIndex {
    static func filter<B>(_ predicate: @escaping (FilterIndexType) -> Bool, iso: Iso<B, Self>) -> Traversal<B, FilterIndexFoci> {
        return iso + filter(predicate)
    }
    
    static func filter<B>(_ predicate: @escaping (FilterIndexType) -> Bool, iso: Iso<FilterIndexFoci, B>) -> Traversal<Self, B> {
        return filter(predicate) + iso
    }
    
    static func filter<F: Traverse, A>(_ predicate: @escaping (FilterIndexType) -> Bool, zipWithIndex: @escaping (Kind<F, A>) -> Kind<F, (A, FilterIndexType)>) -> Traversal<Kind<F, A>, A> where Self: Kind<F, A>, A == FilterIndexFoci {
        return FilterIndexFromTraverseTraversal(zipWithIndex: zipWithIndex, predicate: predicate)
    }
}

private class FilterIndexFromTraverseTraversal<S: Traverse, A, I>: Traversal<Kind<S, A>, A> {
    private let zipWithIndex: (Kind<S, A>) -> Kind<S, (A, I)>
    private let predicate: (I) -> Bool

    init(zipWithIndex: @escaping (Kind<S, A>) -> Kind<S, (A, I)>, predicate: @escaping (I) -> Bool) {
        self.zipWithIndex = zipWithIndex
        self.predicate = predicate
    }

    override func modifyF<F: Applicative>(_ s: Kind<S, A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, Kind<S, A>> {
        return S.traverse(zipWithIndex(s), { x in
            self.predicate(x.1) ? f(x.0): F.pure(x.0)
        })
    }
}
