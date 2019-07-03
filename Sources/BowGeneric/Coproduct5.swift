import Bow

/// Witness for the `Coproduct5` data type. To be used in simulated Higher Kinded Types.
public final class ForCoproduct5 {}

/// Higher Kinded Type alias to improve readability over `Kind5`.
public typealias Coproduct5Of<A, B, C, D, E> = Kind5<ForCoproduct5, A, B, C, D, E>

/// Represents a sum type of 5 different types.
public final class Coproduct5<A, B, C, D, E>: Coproduct5Of<A, B, C, D, E> {
    private let cop: Cop5<A, B, C, D, E>

    private init(_ cop: Cop5<A, B, C, D, E>) {
        self.cop = cop
    }

    /// Creates an instance of a coproduct providing a value of the first type.
    ///
    /// - Parameter a: Value of the first type of the coproduct.
    /// - Returns: A coproduct with a value of the first type.
    public static func first(_ a: A) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.first(a))
    }

    /// Creates an instance of a coproduct providing a value of the second type.
    ///
    /// - Parameter b: Value of the second type of the coproduct.
    /// - Returns: A coproduct with a value of the second type.
    public static func second(_ b: B) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.second(b))
    }

    /// Creates an instance of a coproduct providing a value of the third type.
    ///
    /// - Parameter c: Value of the third type of the coproduct.
    /// - Returns: A coproduct with a value of the third type.
    public static func third(_ c: C) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.third(c))
    }

    /// Creates an instance of a coproduct providing a value of the fourth type.
    ///
    /// - Parameter d: Value of the fourth type of the coproduct.
    /// - Returns: A coproduct with a value of the fourth type.
    public static func fourth(_ d: D) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.fourth(d))
    }

    /// Creates an instance of a coproduct providing a value of the fifth type.
    ///
    /// - Parameter e: Value of the fifth type of the coproduct.
    /// - Returns: A coproduct with a value of the fifth type.
    public static func fifth(_ e: E) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.fifth(e))
    }

    /// Applies a function depending on the content of the coproduct.
    ///
    /// - Parameters:
    ///   - fa: Function to apply with a value of the first type.
    ///   - fb: Function to apply with a value of the second type.
    ///   - fc: Function to apply with a value of the third type.
    ///   - fd: Function to apply with a value of the fourth type.
    ///   - fe: Function to apply with a value of the fifth type.
    /// - Returns: A value resulting of the application of the corresponding function based on the content of the coproduct.
    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z,
                        _ fc: (C) -> Z,
                        _ fd: (D) -> Z,
                        _ fe: (E) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        case let .third(c): return fc(c)
        case let .fourth(d): return fd(d)
        case let .fifth(e): return fe(e)
        }
    }

    /// Retrieves the value of the first type, if present.
    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the second type, if present.
    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the third type, if present.
    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the fourth type, if present.
    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

    /// Retrieves the value of the fifth type, if present.
    public var fifth: Option<E> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some)
    }
}

private enum Cop5<A, B, C, D, E> {
    case first(A)
    case second(B)
    case third(C)
    case fourth(D)
    case fifth(E)
}
