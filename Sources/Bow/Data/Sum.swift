import Foundation

/// Witness for the `Sum<F, G, V>` data type. To be used in simulated Higher Kinded Types.
public final class ForSum {}

/// Partial application of the Sum type constructor, omitting the last parameter.
public final class SumPartial<F, G>: Kind2<ForSum, F, G> {}

/// Higher Kinded Type alias to improve readability of `Kind<SumPartial<F, G>, V>`.
public typealias SumOf<F, G, V> = Kind<SumPartial<F, G>, V>

/// Witness for the `SumOpt<G, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForSumOpt = ForSum

/// Partial application of the SumOpt type constructor, omitting the last parameter.
public typealias SumOptPartial<G> = SumPartial<ForId, G>

/// Higher Kinded Type alias to improve readability of `Kind<SumPartial<G>, A>`.
public typealias SumOptOf<G, A> = SumOf<ForId, G, A>

/// SumOpt is equivalent to Sum where the left side is fixed to Id.
public typealias SumOpt<G, A> = Sum<ForId, G, A>

/// Models the side that is selected in a Sum.
public enum Side {
    case left
    case right
}

/// The Sum type models a Comonad that contains two different Comonadic values, where only one of them can be selected at a given moment.
public final class Sum<F, G, V>: SumOf<F, G, V> {
    /// Left side of this value.
    public let left: Kind<F, V>
    
    /// Right side of this value.
    public let right: Kind<G, V>
    
    /// Selected side.
    public let side: Side
    
    /// Safe downcast.
    ///
    /// - Parameter value: Value in the higher-kind form.
    /// - Returns: Value cast to Sum.
    public static func fix(_ value: SumOf<F, G, V>) -> Sum<F, G, V> {
        value as! Sum<F, G, V>
    }
    
    /// Constructs a Sum value selecting the left side.
    ///
    /// - Parameters:
    ///   - left: Left side of the Sum.
    ///   - right: Right side of the Sum.
    /// - Returns: The Sum of both values, with left selected.
    public static func left(_ left: Kind<F, V>, _ right: Kind<G, V>) -> Sum<F, G, V> {
        Sum(left: left, right: right, side: .left)
    }
    
    /// Constructs a Sum value selecting the right side.
    ///
    /// - Parameters:
    ///   - left: Left side of the Sum.
    ///   - right: Right side of the Sum.
    /// - Returns: The Sum of both values, with right selected.
    public static func right(_ left: Kind<F, V>, _ right: Kind<G, V>) -> Sum<F, G, V> {
        Sum(left: left, right: right, side: .right)
    }
    
    /// Initializes a Sum value.
    ///
    /// - Parameters:
    ///   - left: Left side of the Sum.
    ///   - right: Right side of the Sum.
    ///   - side: Selected side of the Sum.
    public init(left: Kind<F, V>, right: Kind<G, V>, side: Side = .left) {
        self.left = left
        self.right = right
        self.side = side
    }
    
    /// Changes the selected side.
    ///
    /// - Parameter side: New selected side.
    /// - Returns: A new Sum with the same contents and the new selected side.
    public func change(side: Side) -> Sum<F, G, V> {
        Sum(left: self.left, right: self.right, side: side)
    }
    
    /// Converts this Sum to an EitherK.
    ///
    /// - Returns: An EitherK.left if the left side of the Sum is selected, or an EitherK.right otherwise.
    public func lower() -> EitherK<F, G, V> {
        switch side {
        case .left: return .init(left)
        case .right: return .init(right)
        }
    }
    
    /// Obtains the left side.
    ///
    /// - Returns: Left side of the Sum.
    public func lowerLeft() -> Kind<F, V> {
        left
    }
    
    /// Obtains the right side.
    ///
    /// - Returns: Right side of the Sum.
    public func lowerRight() -> Kind<G, V> {
        right
    }
}

public extension Sum where F: Comonad, G: Comonad {
    /// Extracts the value inside the comonadic value that is not selected.
    ///
    /// - Returns: Value contained in the not selected comonadic value.
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

// MARK: Instance of Invariant for Sum

extension SumPartial: Invariant where F: Functor, G: Functor {}

// MARK: Instance of Functor for Sum

extension SumPartial: Functor where F: Functor, G: Functor {
    public static func map<A, B>(
        _ fa: SumOf<F, G, A>,
        _ f: @escaping (A) -> B) -> SumOf<F, G, B> {
        Sum(left: fa^.left.map(f),
            right: fa^.right.map(f),
            side: fa^.side)
    }
}

// MARK: Instance of Comonad for Sum

extension SumPartial: Comonad where F: Comonad, G: Comonad {
    public static func coflatMap<A, B>(
        _ fa: SumOf<F, G, A>,
        _ f: @escaping (SumOf<F, G, A>) -> B) -> SumOf<F, G, B> {
        Sum(left: fa^.left.coflatMap { l in f(Sum(left: l, right: fa^.right, side: .left)) },
            right: fa^.right.coflatMap { r in f(Sum(left: fa^.left, right: r, side: .right)) },
            side: fa^.side)
    }

    public static func extract<A>(_ fa: SumOf<F, G, A>) -> A {
        switch fa^.side {
        case .left: return fa^.left.extract()
        case .right: return fa^.right.extract()
        }
    }
}
