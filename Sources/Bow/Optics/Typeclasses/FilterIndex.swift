import Foundation

public protocol FilterIndex {
    associatedtype S
    associatedtype I
    associatedtype A
    
    func filter(_ predicate : @escaping (I) -> Bool) -> Traversal<S, A>
}

public extension FilterIndex {
    public static func filterIndex<FilterIdx>(_ fi : FilterIdx, _ predicate : @escaping (I) -> Bool) -> Traversal<S, A> where FilterIdx : FilterIndex, FilterIdx.S == S, FilterIdx.I == I, FilterIdx.A == A {
        return fi.filter(predicate)
    }
    
    public static func fromIso<FilterIdx, B>(_ fi : FilterIdx, _ iso : Iso<S, A>) -> FilterIndexFromIso<S, I, B, A, FilterIdx> where FilterIdx : FilterIndex, FilterIdx.S == A, FilterIdx.I == I, FilterIdx.A == B {
        return FilterIndexFromIso<S, I, B, A, FilterIdx>(filterIndex: fi, iso: iso)
    }
    
    public static func from<Trav>(traverse : Trav, zipWithIndex : @escaping (Kind<S, A>) -> Kind<S, (A, Int)>) -> FilterIndexFromTraverse<S, A, Trav> where Trav : Traverse, Trav.F == S {
        return FilterIndexFromTraverse(zipWithIndex: zipWithIndex, traverse: traverse)
    }
}

public class FilterIndexFromIso<M, N, O, P, FilterIdx> : FilterIndex where FilterIdx : FilterIndex, FilterIdx.S == P, FilterIdx.I == N, FilterIdx.A == O {
    public typealias S = M
    public typealias I = N
    public typealias A = O
    
    private let filterIndex : FilterIdx
    private let iso : Iso<M, P>
    
    public init(filterIndex : FilterIdx, iso : Iso<M, P>) {
        self.filterIndex = filterIndex
        self.iso = iso
    }
    
    public func filter(_ predicate: @escaping (N) -> Bool) -> Traversal<M, O> {
        return iso + filterIndex.filter(predicate)
    }
}

public class FilterIndexFromTraverse<M, N, Trav> : FilterIndex where Trav : Traverse, Trav.F == M {
    public typealias S = Kind<M, N>
    public typealias I = Int
    public typealias A = N
    
    private let zipWithIndex : (Kind<M, N>) -> Kind<M, (N, Int)>
    private let traverse : Trav
    
    public init(zipWithIndex : @escaping (Kind<M, N>) -> Kind<M, (N, Int)>, traverse : Trav) {
        self.zipWithIndex = zipWithIndex
        self.traverse = traverse
    }
    
    public func filter(_ predicate: @escaping (Int) -> Bool) -> Traversal<Kind<M, N>, N> {
        return FilterIndexFromTraverseTraversal(
            zipWithIndex: zipWithIndex,
            traverse: traverse,
            predicate: predicate)
    }
}

fileprivate class FilterIndexFromTraverseTraversal<S, A, Trav> : Traversal<Kind<S, A>, A> where Trav : Traverse, Trav.F == S {
    
    private let zipWithIndex : (Kind<S, A>) -> Kind<S, (A, Int)>
    private let traverse : Trav
    private let predicate : (Int) -> Bool
    
    init(zipWithIndex : @escaping (Kind<S, A>) -> Kind<S, (A, Int)>, traverse : Trav, predicate : @escaping (Int) -> Bool) {
        self.zipWithIndex = zipWithIndex
        self.traverse = traverse
        self.predicate = predicate
    }
    
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: Kind<S, A>, _ f: @escaping (A) -> Kind<F, A>) -> Kind<F, Kind<S, A>> where Appl : Applicative, F == Appl.F {
        return traverse.traverse(zipWithIndex(s), { x in
            self.predicate(x.1) ? f(x.0) : applicative.pure(x.0)
        }, applicative)
    }
}
