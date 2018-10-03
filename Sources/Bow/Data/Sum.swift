import Foundation

public class ForSum {}
public typealias SumOf<F, G, V> = Kind3<ForSum, F, G, V>
public typealias SumPartial<F, G> = Kind2<ForSum, F, G>

public enum Side {
    case left
    case right
}

public class Sum<F, G, V> : SumOf<F, G, V> {
    public let left : Kind<F, V>
    public let right : Kind<G, V>
    public let side : Side
    
    public static func fix(_ value : SumOf<F, G, V>) -> Sum<F, G, V> {
        return value as! Sum<F, G, V>
    }
    
    public static func left(_ left : Kind<F, V>, _ right : Kind<G, V>) -> Sum<F, G, V> {
        return Sum(left: left, right: right, side: .left)
    }
    
    public static func right(_ left : Kind<F, V>, _ right : Kind<G, V>) -> Sum<F, G, V> {
        return Sum(left: left, right: right, side: .right)
    }

    public init(left : Kind<F, V>, right : Kind<G, V>, side : Side = .left) {
        self.left = left
        self.right = right
        self.side = side
    }
    
    public func coflatMap<A, ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG, _ f : @escaping (Sum<F, G, V>) -> A) -> Sum<F, G, A> where ComonF : Comonad, ComonF.F == F, ComonG : Comonad, ComonG.F == G {
        return Sum<F, G, A>(left: comonadF.coflatMap(self.left, { _ in f(Sum(left: self.left, right: self.right, side: .left)) }),
                            right: comonadG.coflatMap(self.right, { _ in f(Sum(left: self.left, right: self.right, side: .right)) }),
                            side: self.side)
    }
    
    public func map<A, FuncF, FuncG>(_ functorF : FuncF, _ functorG : FuncG, _ f : @escaping (V) -> A) -> Sum<F, G, A> where FuncF : Functor, FuncF.F == F, FuncG : Functor, FuncG.F == G {
        return Sum<F, G, A>(left: functorF.map(self.left, f),
                            right: functorG.map(self.right, f),
                            side: self.side)
    }
    
    public func extract<ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG) -> V where ComonF : Comonad, ComonF.F == F, ComonG : Comonad, ComonG.F == G {
        switch self.side {
        case .left: return comonadF.extract(self.left)
        case .right: return comonadG.extract(self.right)
        }
    }
    
    public func change(side: Side) -> Sum<F, G, V> {
        return Sum(left: self.left, right: self.right, side: side)
    }
}

public extension Sum {
    public static func functor<FuncF, FuncG>(_ functorF : FuncF, _ functorG : FuncG) -> SumFunctor<F, G, FuncF, FuncG> {
        return SumFunctor(functorF, functorG)
    }
    
    public static func comonad<ComonF, ComonG>(_ comonadF : ComonF, _ comonadG : ComonG) -> SumComonad<F, G, ComonF, ComonG> {
        return SumComonad(comonadF, comonadG)
    }
}

public class SumFunctor<G, H, FuncG, FuncH> : Functor where FuncG : Functor, FuncG.F == G, FuncH : Functor, FuncH.F == H {
    public typealias F = SumPartial<G, H>
    
    private let functorG : FuncG
    private let functorH : FuncH
    
    public init(_ functorG : FuncG, _ functorH : FuncH) {
        self.functorG = functorG
        self.functorH = functorH
    }
    
    public func map<A, B>(_ fa: SumOf<G, H, A>, _ f: @escaping (A) -> B) -> SumOf<G, H, B> {
        return Sum<G, H, A>.fix(fa).map(functorG, functorH, f)
    }
}

public class SumComonad<G, H, ComonG, ComonH> : SumFunctor<G, H, ComonG, ComonH>, Comonad where ComonG : Comonad, ComonG.F == G, ComonH : Comonad, ComonH.F == H {
    
    private let comonadG : ComonG
    private let comonadH : ComonH
    
    override public init(_ comonadG : ComonG, _ comonadH : ComonH) {
        self.comonadG = comonadG
        self.comonadH = comonadH
        super.init(comonadG, comonadH)
    }
    
    public func coflatMap<A, B>(_ fa: SumOf<G, H, A>, _ f: @escaping (SumOf<G, H, A>) -> B) -> SumOf<G, H, B> {
        return Sum<G, H, A>.fix(fa).coflatMap(comonadG, comonadH, f)
    }
    
    public func extract<A>(_ fa: SumOf<G, H, A>) -> A {
        return Sum<G, H, A>.fix(fa).extract(comonadG, comonadH)
    }
    
    
}
