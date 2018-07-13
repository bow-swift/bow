import Foundation

public protocol Each {
    associatedtype S
    associatedtype A
    
    func each() -> Traversal<S, A>
}

public extension Each {
    public static func fromIso<B, EachIn>(_ each : EachIn, _ iso : Iso<S, A>) -> EachFromIso<S, B, A, EachIn> where EachIn : Each, EachIn.S == A, EachIn.A == B {
        return EachFromIso<S, B, A, EachIn>(each : each, iso : iso)
    }
    
    public static func from<Trav>(traverse : Trav) -> EachFromTraverse<S, A, Trav> where Trav : Traverse, Trav.F == S {
        return EachFromTraverse<S, A, Trav>(traverse: traverse)
    }
}

public class EachFromIso<M, N, O, EachIn> : Each where EachIn : Each, EachIn.S == O, EachIn.A == N {
    public typealias S = M
    public typealias A = N
    
    private let eachObject : EachIn
    private let iso : Iso<S, O>
    
    public init(each eachObject : EachIn, iso : Iso<S, O>) {
        self.eachObject = eachObject
        self.iso = iso
    }
    
    public func each() -> Traversal<M, N> {
        return iso + eachObject.each()
    }
}

public class EachFromTraverse<M, N, Trav> : Each where Trav : Traverse, Trav.F == M {
    public typealias S = Kind<M, N>
    public typealias A = N
    
    private let traverse : Trav
    
    public init(traverse : Trav) {
        self.traverse = traverse
    }

    public func each() -> Traversal<Kind<M, N>, N> {
        return Traversal<S, A>.from(traverse: traverse)
    }
}
