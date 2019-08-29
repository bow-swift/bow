import Bow

/// Witness for the `Coproduct9` data type. To be used in simulated Higher Kinded Types.
public final class ForCoproduct9 {}

/// Higher Kinded Type alias to improve readability over `Kind9`.
public typealias Coproduct9Of<A, B, C, D, E, F, G, H, I> = Kind9<ForCoproduct9, A, B, C, D, E, F, G, H, I>

/// Represents a sum type of 9 different types.
public final class Coproduct9<A, B, C, D, E, F, G, H, I>: Coproduct9Of<A, B, C, D, E, F, G, H, I> {
    private let cop: Cop9<A, B, C, D, E, F, G, H, I>

    private init(_ cop: Cop9<A, B, C, D, E, F, G, H, I>) {
        self.cop = cop
    }

    /// Creates an instance of a coproduct providing a value of the first type.
    ///
    /// - Parameter a: Value of the first type of the coproduct.
    /// - Returns: A coproduct with a value of the first type.
    public static func first(_ a: A) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.first(a))
    }

    /// Creates an instance of a coproduct providing a value of the second type.
    ///
    /// - Parameter b: Value of the second type of the coproduct.
    /// - Returns: A coproduct with a value of the second type.
    public static func second(_ b: B) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.second(b))
    }

    /// Creates an instance of a coproduct providing a value of the third type.
    ///
    /// - Parameter c: Value of the third type of the coproduct.
    /// - Returns: A coproduct with a value of the third type.
    public static func third(_ c: C) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.third(c))
    }

    /// Creates an instance of a coproduct providing a value of the fourth type.
    ///
    /// - Parameter d: Value of the fourth type of the coproduct.
    /// - Returns: A coproduct with a value of the fourth type.
    public static func fourth(_ d: D) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.fourth(d))
    }

    /// Creates an instance of a coproduct providing a value of the fifth type.
    ///
    /// - Parameter e: Value of the fifth type of the coproduct.
    /// - Returns: A coproduct with a value of the fifth type.
    public static func fifth(_ e: E) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.fifth(e))
    }

    /// Creates an instance of a coproduct providing a value of the sixth type.
    ///
    /// - Parameter f: Value of the sixth type of the coproduct.
    /// - Returns: A coproduct with a value of the sixth type.
    public static func sixth(_ f: F) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.sixth(f))
    }

    /// Creates an instance of a coproduct providing a value of the seventh type.
    ///
    /// - Parameter g: Value of the seventh type of the coproduct.
    /// - Returns: A coproduct with a value of the seventh type.
    public static func seventh(_ g: G) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.seventh(g))
    }

    /// Creates an instance of a coproduct providing a value of the eighth type.
    ///
    /// - Parameter h: Value of the eighth type of the coproduct.
    /// - Returns: A coproduct with a value of the eighth type.
    public static func eighth(_ h: H) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.eighth(h))
    }

    /// Creates an instance of a coproduct providing a value of the ninth type.
    ///
    /// - Parameter i: Value of the ninth type of the coproduct.
    /// - Returns: A coproduct with a value of the ninth type.
    public static func ninth(_ i: I) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.ninth(i))
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
    ///   - fg: Function to apply with a value of the seventh type.
    ///   - fh: Function to apply with a value of the eighth type.
    ///   - fi: Function to apply with a value of the ninth type.
    /// - Returns: A value resulting of the application of the corresponding function based on the content of the coproduct.
    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z,
                        _ fc: (C) -> Z,
                        _ fd: (D) -> Z,
                        _ fe: (E) -> Z,
                        _ ff: (F) -> Z,
                        _ fg: (G) -> Z,
                        _ fh: (H) -> Z,
                        _ fi: (I) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        case let .third(c): return fc(c)
        case let .fourth(d): return fd(d)
        case let .fifth(e): return fe(e)
        case let .sixth(f): return ff(f)
        case let .seventh(g): return fg(g)
        case let .eighth(h): return fh(h)
        case let .ninth(i): return fi(i)
        }
    }

    /// Retrieves the value of the first type, if present.
    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the second type, if present.
    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the third type, if present.
    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the fourth type, if present.
    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the fifth type, if present.
    public var fifth: Option<E> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the sixth type, if present.
    public var sixth: Option<F> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the seventh type, if present.
    public var seventh: Option<G> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    /// Retrieves the value of the eighth type, if present.
    public var eighth: Option<H> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

    /// Retrieves the value of the ninth type, if present.
    public var ninth: Option<I> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some)
    }
}

private enum Cop9<A, B, C, D, E, F, G, H, I> {
    case first(A)
    case second(B)
    case third(C)
    case fourth(D)
    case fifth(E)
    case sixth(F)
    case seventh(G)
    case eighth(H)
    case ninth(I)
}
