import Foundation

public final class ForSum {}
public final class SumPartial<F, G>: Kind2<ForSum, F, G> {}
public typealias SumOf<F, G, V> = Kind<SumPartial<F, G>, V>

public typealias SumOptPartial<G> = SumPartial<ForId, G>
public typealias SumOptOf<G, A> = SumOf<ForId, G, A>
public typealias SumOpt<G, A> = Sum<ForId, G, A>

public enum Side {
    case left
    case right
}

public final class Sum<F, G, V> : SumOf<F, G, V> {
    public let left: Kind<F, V>
    public let right: Kind<G, V>
    public let side: Side
    
    public static func fix(_ value: SumOf<F, G, V>) -> Sum<F, G, V> {
        value as! Sum<F, G, V>
    }
    
    public static func left(_ left: Kind<F, V>, _ right: Kind<G, V>) -> Sum<F, G, V> {
        Sum(left: left, right: right, side: .left)
    }
    
    public static func right(_ left: Kind<F, V>, _ right: Kind<G, V>) -> Sum<F, G, V> {
        Sum(left: left, right: right, side: .right)
    }

    public init(left: Kind<F, V>, right: Kind<G, V>, side: Side = .left) {
        self.left = left
        self.right = right
        self.side = side
    }
    
    public func change(side: Side) -> Sum<F, G, V> {
        Sum(left: self.left, right: self.right, side: side)
    }
    
    public func lower() -> EitherK<F, G, V> {
        switch side {
        case .left: return .init(left)
        case .right: return .init(right)
        }
    }
    
    public func lowerLeft() -> Kind<F, V> {
        left
    }
    
    public func lowerRight() -> Kind<G, V> {
        right
    }
}

public extension Sum where F: Comonad, G: Comonad {
    func extractOther() -> V {
        switch side {
        case .left: return right.extract()
        case .right: return left.extract()
        }
    }
}

/// Safe downcast.
///
/// - Parameter value: Value in higher-kind form.
/// - Returns: Value cast to Sum.
public postfix func ^<F, G, V>(_ value: SumOf<F, G, V>) -> Sum<F, G, V> {
    Sum.fix(value)
}

extension SumPartial: Invariant where F: Functor, G: Functor {}

extension SumPartial: Functor where F: Functor, G: Functor {
    public static func map<A, B>(_ fa: Kind<SumPartial<F, G>, A>, _ f: @escaping (A) -> B) -> Kind<SumPartial<F, G>, B> {
        Sum(left: fa^.left.map(f),
            right: fa^.right.map(f),
            side: fa^.side)
    }
}

extension SumPartial: Comonad where F: Comonad, G: Comonad {
    public static func coflatMap<A, B>(_ fa: Kind<SumPartial<F, G>, A>, _ f: @escaping (Kind<SumPartial<F, G>, A>) -> B) -> Kind<SumPartial<F, G>, B> {
        Sum(left: fa^.left.coflatMap { l in f(Sum(left: l, right: fa^.right, side: .left)) },
            right: fa^.right.coflatMap { r in f(Sum(left: fa^.left, right: r, side: .right)) },
            side: fa^.side)
    }

    public static func extract<A>(_ fa: Kind<SumPartial<F, G>, A>) -> A {
        switch fa^.side {
        case .left: return fa^.left.extract()
        case .right: return fa^.right.extract()
        }
    }
}
