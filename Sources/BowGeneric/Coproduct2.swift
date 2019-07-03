import Bow

/// Witness for the `Coproduct2` data type. To be used in simulated Higher Kinded Types.
public final class ForCoproduct2 {}

/// Higher Kinded Type alias to improve readability over `Kind2`.
public typealias Coproduct2Of<A, B> = Kind2<ForCoproduct2, A, B>

/// Represents a sum type of 2 different types.
public final class Coproduct2<A, B>: Coproduct2Of<A, B> {
    private let cop: Cop2<A, B>

    private init(_ cop: Cop2<A, B>) {
        self.cop = cop
    }

    /// Creates an instance of a coproduct providing a value of the first type.
    ///
    /// - Parameter a: Value of the first type of the coproduct.
    /// - Returns: A coproduct with a value of the first type.
    public static func first(_ a: A) -> Coproduct2<A, B> {
        return Coproduct2(.first(a))
    }

    /// Creates an instance of a coproduct providing a value of the second type.
    ///
    /// - Parameter b: Value of the second type of the coproduct.
    /// - Returns: A coproduct with a value of the second type.
    public static func second(_ b: B) -> Coproduct2<A, B> {
        return Coproduct2(.second(b))
    }

    /// Applies a function depending on the content of the coproduct.
    ///
    /// - Parameters:
    ///   - fa: Function to apply with a value of the first type.
    ///   - fb: Function to apply with a value of the second type.
    /// - Returns: A value resulting of the application of the corresponding function based on the content of the coproduct.
    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        }
    }

    /// Retrieves the value of the first type, if present.
    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()))
    }

    /// Retrieves the value of the second type, if present.
    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some)
    }
}

private enum Cop2<A, B> {
    case first(A)
    case second(B)
}
