import Foundation
import Bow

public protocol Each {
    associatedtype EachFoci

    static var each: Traversal<Self, EachFoci> { get }
}

//public extension Each {
//    static func fromIso<B, EachIn>(_ each : EachIn, _ iso : Iso<S, A>) -> EachFromIso<S, B, A, EachIn> where EachIn : Each, EachIn.S == A, EachIn.A == B {
//        return EachFromIso<S, B, A, EachIn>(each : each, iso : iso)
//    }
//}
//
//public extension Each where S: Traverse {
//    static func from() -> EachFromTraverse<S, A>  {
//        return EachFromTraverse<S, A>()
//    }
//}
//
//public class EachFromIso<M, N, O, EachIn> : Each where EachIn : Each, EachIn.S == O, EachIn.A == N {
//    public typealias S = M
//    public typealias A = N
//
//    private let eachObject : EachIn
//    private let iso : Iso<S, O>
//
//    public init(each eachObject : EachIn, iso : Iso<S, O>) {
//        self.eachObject = eachObject
//        self.iso = iso
//    }
//
//    public func each() -> Traversal<M, N> {
//        return iso + eachObject.each()
//    }
//}
//
//public class EachFromTraverse<M: Traverse, N>: Each {
//    public typealias S = Kind<M, N>
//    public typealias A = N
//
//    public init() {}
//
//    public func each() -> Traversal<Kind<M, N>, N> {
//        return Traversal<S, A>.fromTraverse()
//    }
//}
