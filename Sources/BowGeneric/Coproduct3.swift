import Bow

/// Witness for the `Coproduct3` data type. To be used in simulated Higher Kinded Types.
public final class ForCoproduct3 {}

/// Higher Kinded Type alias to improve readability over `Kind3`.
public typealias Coproduct3Of<A, B, C> = Kind3<ForCoproduct3, A, B, C>

/// Represents a sum type of 3 different types.
public final class Coproduct3<A, B, C>: Coproduct3Of<A, B, C> {
    private let cop: Cop3<A, B, C>

    private init(_ cop: Cop3<A, B, C>) {
        self.cop = cop
    }

    /// Creates an instance of a coproduct providing a value of the first type.
    ///
    /// - Parameter a: Value of the first type of the coproduct.
    /// - Returns: A coproduct with a value of the first type.
    public static func first(_ a: A) -> Coproduct3<A, B, C> {
        return Coproduct3(.first(a))
    }

    /// Creates an instance of a coproduct providing a value of the second type.
    ///
    /// - Parameter b: Value of the second type of the coproduct.
    /// - Returns: A coproduct with a value of the second type.
    public static func second(_ b: B) -> Coproduct3<A, B, C> {
        return Coproduct3(.second(b))
    }

    /// Creates an instance of a coproduct providing a value of the third type.
    ///
    /// - Parameter c: Value of the third type of the coproduct.
    /// - Returns: A coproduct with a value of the third type.
    public static func third(_ c: C) -> Coproduct3<A, B, C> {
        return Coproduct3(.third(c))
    }

    /// Applies a function depending on the content of the coproduct.
    ///
    /// - Parameters:
    ///   - fa: Function to apply with a value of the first type.
    ///   - fb: Function to apply with a value of the second type.
    ///   - fc: Function to apply with a value of the third type.
    /// - Returns: A value resulting of the application of the corresponding function based on the content of the coproduct.
    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z,
                        _ fc: (C) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        case let .third(c): return fc(c)
        }
    }

    /// Retrieves the value of the first type, if present.
    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the second type, if present.
    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()))
    }

    /// Retrieves the value of the third type, if present.
    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some)
    }
}

private enum Cop3<A, B, C> {
    case first(A)
    case second(B)
    case third(C)
}
