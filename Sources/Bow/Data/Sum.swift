import Foundation

public class ForSum {}
public typealias SumOf<F, G, V> = Kind3<ForSum, F, G, V>

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
