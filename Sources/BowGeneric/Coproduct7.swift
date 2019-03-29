import Bow

public final class ForCoproduct7 {}
public typealias Coproduct7Of<A, B, C, D, E, F, G> = Kind7<ForCoproduct7, A, B, C, D, E, F, G>

public final class Coproduct7<A, B, C, D, E, F, G>: Coproduct7Of<A, B, C, D, E, F, G> {
    private let cop: Cop7<A, B, C, D, E, F, G>

    private init(_ cop: Cop7<A, B, C, D, E, F, G>) {
        self.cop = cop
    }

    public static func first(_ a: A) -> Coproduct7<A, B, C, D, E, F, G> {
        return Coproduct7(.first(a))
    }

    public static func second(_ b: B) -> Coproduct7<A, B, C, D, E, F, G> {
        return Coproduct7(.second(b))
    }

    public static func third(_ c: C) -> Coproduct7<A, B, C, D, E, F, G> {
        return Coproduct7(.third(c))
    }

    public static func fourth(_ d: D) -> Coproduct7<A, B, C, D, E, F, G> {
        return Coproduct7(.fourth(d))
    }

    public static func fifth(_ e: E) -> Coproduct7<A, B, C, D, E, F, G> {
        return Coproduct7(.fifth(e))
    }

    public static func sixth(_ f: F) -> Coproduct7<A, B, C, D, E, F, G> {
        return Coproduct7(.sixth(f))
    }

    public static func seventh(_ g: G) -> Coproduct7<A, B, C, D, E, F, G> {
        return Coproduct7(.seventh(g))
    }

    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z,
                        _ fc: (C) -> Z,
                        _ fd: (D) -> Z,
                        _ fe: (E) -> Z,
                        _ ff: (F) -> Z,
                        _ fg: (G) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        case let .third(c): return fc(c)
        case let .fourth(d): return fd(d)
        case let .fifth(e): return fe(e)
        case let .sixth(f): return ff(f)
        case let .seventh(g): return fg(g)
        }
    }

    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var fifth: Option<E> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    public var sixth: Option<F> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

    public var seventh: Option<G> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some)
    }
}

private enum Cop7<A, B, C, D, E, F, G> {
    case first(A)
    case second(B)
    case third(C)
    case fourth(D)
    case fifth(E)
    case sixth(F)
    case seventh(G)
}
