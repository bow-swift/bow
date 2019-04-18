import Bow

public final class ForCoproduct5 {}
public typealias Coproduct5Of<A, B, C, D, E> = Kind5<ForCoproduct5, A, B, C, D, E>

public final class Coproduct5<A, B, C, D, E>: Coproduct5Of<A, B, C, D, E> {
    private let cop: Cop5<A, B, C, D, E>

    private init(_ cop: Cop5<A, B, C, D, E>) {
        self.cop = cop
    }

    public static func first(_ a: A) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.first(a))
    }

    public static func second(_ b: B) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.second(b))
    }

    public static func third(_ c: C) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.third(c))
    }

    public static func fourth(_ d: D) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.fourth(d))
    }

    public static func fifth(_ e: E) -> Coproduct5<A, B, C, D, E> {
        return Coproduct5(.fifth(e))
    }

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

    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

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
