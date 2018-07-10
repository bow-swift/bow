import Foundation

public protocol At : Typeclass {
    associatedtype S
    associatedtype I
    associatedtype A
    
    func at(_ i : I) -> Lens<S, A>
}

public extension At {
    public static func at<AtType>(_ at : AtType, _ i : I) -> Lens<S, A> where AtType : At, AtType.S == S, AtType.I == I, AtType.A == A {
        return at.at(i)
    }
    
    public static func fromIso<U, AtType>(_ at : AtType, _ iso : Iso<S, U>) -> AtFromIso<S, I, A, U, AtType> where AtType : At, AtType.S == U, AtType.I == I, AtType.A == A {
        return AtFromIso(at: at, iso: iso)
    }
}

public class AtFromIso<M, N, O, P, AtType> : At where AtType : At, AtType.S == P, AtType.I == N, AtType.A == O {
    public typealias S = M
    public typealias I = N
    public typealias A = O
    
    private let atInstance : AtType
    private let iso : Iso<M, P>
    
    public init(at : AtType, iso : Iso<M, P>) {
        self.atInstance = at
        self.iso = iso
    }
    
    public func at(_ i: N) -> Lens<M, O> {
        return iso + atInstance.at(i)
    }
    
}
