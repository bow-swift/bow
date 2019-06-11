import Foundation

public final class ForSum {}
public final class SumPartial<F, G>: Kind2<ForSum, F, G> {}
public typealias SumOf<F, G, V> = Kind<SumPartial<F, G>, V>

public enum Side {
    case left
    case right
}

public final class Sum<F, G, V> : SumOf<F, G, V> {
    public let left: Kind<F, V>
    public let right: Kind<G, V>
    public let side: Side
    
    public static func fix(_ value: SumOf<F, G, V>) -> Sum<F, G, V> {
        return value as! Sum<F, G, V>
    }
    
    public static func left(_ left: Kind<F, V>, _ right: Kind<G, V>) -> Sum<F, G, V> {
        return Sum(left: left, right: right, side: .left)
    }
    
    public static func right(_ left: Kind<F, V>, _ right: Kind<G, V>) -> Sum<F, G, V> {
        return Sum(left: left, right: right, side: .right)
    }

    public init(left: Kind<F, V>, right: Kind<G, V>, side: Side = .left) {
        self.left = left
        self.right = right
        self.side = side
    }
    
    public func change(side: Side) -> Sum<F, G, V> {
        return Sum(left: self.left, right: self.right, side: side)
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Sum.
public postfix func ^<F, G, V>(_ value: SumOf<F, G, V>) -> Sum<F, G, V> {
    return Sum.fix(value)
}

extension SumPartial: Invariant where F: Functor, G: Functor {}

extension SumPartial: Functor where F: Functor, G: Functor {
    public static func map<A, B>(_ fa: Kind<SumPartial<F, G>, A>, _ f: @escaping (A) -> B) -> Kind<SumPartial<F, G>, B> {
        let sum = Sum.fix(fa)
        return Sum(left: sum.left.map(f),
                   right: sum.right.map(f),
                   side: sum.side)
    }
}

extension SumPartial: Comonad where F: Comonad, G: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<SumPartial<F, G>, A>, _ f: @escaping (Kind<SumPartial<F, G>, A>) -> B) -> Kind<SumPartial<F, G>, B> {
        let sum = Sum.fix(fa)
        return Sum(left: F.coflatMap(sum.left, { _ in f(Sum(left: sum.left, right: sum.right, side: .left)) }),
                   right: G.coflatMap(sum.right, { _ in f(Sum(left: sum.left, right: sum.right, side: .right)) }),
                   side: sum.side)
    }

    public static func extract<A>(_ fa: Kind<SumPartial<F, G>, A>) -> A {
        let sum = Sum.fix(fa)
        switch sum.side {
        case .left: return F.extract(sum.left)
        case .right: return G.extract(sum.right)
        }
    }
}
