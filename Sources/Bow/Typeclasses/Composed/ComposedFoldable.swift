import Foundation

public protocol ComposedFoldable : Foldable where F == Nested<G, H>, FoldG : Foldable, FoldG.F == G, FoldH : Foldable, FoldH.F == H {
    associatedtype G
    associatedtype H
    associatedtype FoldG
    associatedtype FoldH
    
    var foldableG : FoldG { get }
    var foldableH : FoldH { get }
}

public extension ComposedFoldable {
    public static func instance(_ foldableG : FoldG, _ foldableH : FoldH) -> BaseComposedFoldable<G, H, FoldG, FoldH> {
        return BaseComposedFoldable<G, H, FoldG, FoldH>(foldableG, foldableH)
    }
    
    public func foldLeft<A, B>(_ fa: Kind<Nested<G, H>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return foldableG.foldLeft(unnest(fa), b, { bb, aa in self.foldableH.foldLeft(aa, bb, f) })
    }
    
    public func foldRight<A, B>(_ fa: Kind<Nested<G, H>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return foldableG.foldRight(unnest(fa), b, { aa, bb in self.foldableH.foldRight(aa, bb, f) })
    }
    
    public func foldLC<A, B>(_ fa : Kind<G, Kind<H, A>>, _ b : B, _ f : @escaping (B, A) -> B) -> B {
        return foldLeft(nest(fa), b, f)
    }
    
    public func foldRC<A, B>(_ fa : Kind<G, Kind<H, A>>, _ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return foldRight(nest(fa), b, f)
    }
}

public class BaseComposedFoldable<A, B, FoldA, FoldB> : ComposedFoldable where FoldA : Foldable, FoldA.F == A, FoldB : Foldable, FoldB.F == B{
    
    public typealias G = A
    public typealias H = B
    public typealias FoldG = FoldA
    public typealias FoldH = FoldB
    
    public var foldableG: FoldA
    public var foldableH: FoldB
    
    public init(_ foldableA : FoldA, _ foldableB : FoldB) {
        self.foldableG = foldableA
        self.foldableH = foldableB
    }
}

public extension Foldable {
    
    public func compose<G, FoldG>(_ otherFoldable : FoldG) -> BaseComposedFoldable<F, G, Self, FoldG> where FoldG : Foldable{
        return BaseComposedFoldable.instance(self, otherFoldable)
    }
}
