import Foundation

public protocol Index : Typeclass {
    associatedtype S
    associatedtype I
    associatedtype A
    
    func index(_ i : I) -> Optional<S, A>
}

public extension Index {
    public static func index<Idx>(_ idx : Idx, _ i : I) -> Optional<S, A> where Idx : Index, Idx.S == S, Idx.I == I, Idx.A == A {
        return idx.index(i)
    }
    
    public static func fromIso<Idx, B>(_ idx : Idx, _ iso : Iso<S, A>) -> IndexFromIso<S, I, B, A, Idx> where Idx : Index, Idx.S == A, Idx.I == I, Idx.A == B {
        return IndexFromIso(index: idx, iso: iso)
    }
}

public class IndexFromIso<M, N, O, P, Idx> : Index where Idx : Index, Idx.S == P, Idx.I == N, Idx.A == O {
    public typealias S = M
    public typealias I = N
    public typealias A = O
    
    private let idx : Idx
    private let iso : Iso<M, P>
    
    public init(index : Idx, iso : Iso<M, P>) {
        self.idx = index
        self.iso = iso
    }
    
    public func index(_ i: N) -> Optional<M, O> {
        return iso + idx.index(i)
    }
}
