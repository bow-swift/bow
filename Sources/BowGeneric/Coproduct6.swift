import Bow

/// Witness for the `Coproduct6` data type. To be used in simulated Higher Kinded Types.
public final class ForCoproduct6 {}

/// Higher Kinded Type alias to improve readability over `Kind6`.
public typealias Coproduct6Of<A, B, C, D, E, F> = Kind6<ForCoproduct6, A, B, C, D, E, F>

/// Represents a sum type of 6 different types.
public final class Coproduct6<A, B, C, D, E, F>: Coproduct6Of<A, B, C, D, E, F> {
    private let cop: Cop6<A, B, C, D, E, F>

    private init(_ cop: Cop6<A, B, C, D, E, F>) {
        self.cop = cop
    }

    /// Creates an instance of a coproduct providing a value of the first type.
    ///
    /// - Parameter a: Value of the first type of the coproduct.
    /// - Returns: A coproduct with a value of the first type.
    public static func first(_ a: A) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.first(a))
    }

    /// Creates an instance of a coproduct providing a value of the second type.
    ///
    /// - Parameter b: Value of the second type of the coproduct.
    /// - Returns: A coproduct with a value of the second type.
    public static func second(_ b: B) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.second(b))
    }

    /// Creates an instance of a coproduct providing a value of the third type.
    ///
    /// - Parameter c: Value of the third type of the coproduct.
    /// - Returns: A coproduct with a value of the third type.
    public static func third(_ c: C) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.third(c))
    }

    /// Creates an instance of a coproduct providing a value of the fourth type.
    ///
    /// - Parameter d: Value of the fourth type of the coproduct.
    /// - Returns: A coproduct with a value of the fourth type.
    public static func fourth(_ d: D) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.fourth(d))
    }

    /// Creates an instance of a coproduct providing a value of the fifth type.
    ///
    /// - Parameter e: Value of the fifth type of the coproduct.
    /// - Returns: A coproduct with a value of the fifth type.
    public static func fifth(_ e: E) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.fifth(e))
    }

    /// Creates an instance of a coproduct providing a value of the sixth type.
    ///
    /// - Parameter f: Value of the sixth type of the coproduct.
    /// - Returns: A coproduct with a value of the sixth type.
    public static func sixth(_ f: F) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.sixth(f))
    }

    /// Applies a function depending on the content of the coproduct.
    ///
    /// - Parameters:
    ///   - fa: Function to apply with a value of the first type.
    ///   - fb: Function to apply with a value of the second type.
    ///   - fc: Function to apply with a value of the third type.
    ///   - fd: Function to apply with a value of the fourth type.
    ///   - fe: Function to apply with a value of the fifth type.
    ///   - ff: Function to apply with a value of the sixth type.
    /// - Returns: A value resulting of the application of the corresponding function based on the content of the coproduct.
    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z,
                        _ fc: (C) -> Z,
                        _ fd: (D) -> Z,
                        _ fe: (E) -> Z,
                        _ ff: (F) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        case let .third(c): return fc(c)
        case let .fourth(d): return fd(d)
        case let .fifth(e): return fe(e)
        case let .sixth(f): return ff(f)
        }
    }

    /// Retrieves the value of the first type, if present.
    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the second type, if present.
    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the third type, if present.
    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the fourth type, if present.
    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the fifth type, if present.
    public var fifth: Option<E> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

    /// Retrieves the value of the sixth type, if present.
    public var sixth: Option<F> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some)
    }
}

private enum Cop6<A, B, C, D, E, F> {
    case first(A)
    case second(B)
    case third(C)
    case fourth(D)
    case fifth(E)
    case sixth(F)
}
