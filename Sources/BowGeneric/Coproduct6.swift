import Bow

public final class ForCoproduct6 {}
public typealias Coproduct6Of<A, B, C, D, E, F> = Kind6<ForCoproduct6, A, B, C, D, E, F>

public final class Coproduct6<A, B, C, D, E, F>: Coproduct6Of<A, B, C, D, E, F> {
    private let cop: Cop6<A, B, C, D, E, F>

    private init(_ cop: Cop6<A, B, C, D, E, F>) {
        self.cop = cop
    }

    public static func first(_ a: A) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.first(a))
    }

    public static func second(_ b: B) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.second(b))
    }

    public static func third(_ c: C) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.third(c))
    }

    public static func fourth(_ d: D) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.fourth(d))
    }

    public static func fifth(_ e: E) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.fifth(e))
    }

    public static func sixth(_ f: F) -> Coproduct6<A, B, C, D, E, F> {
        return Coproduct6(.sixth(f))
    }

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

    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    public var fifth: Option<E> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

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
