import Bow

public final class ForCoproduct8 {}
public typealias Coproduct8Of<A, B, C, D, E, F, G, H> = Kind8<ForCoproduct8, A, B, C, D, E, F, G, H>

public final class Coproduct8<A, B, C, D, E, F, G, H>: Coproduct8Of<A, B, C, D, E, F, G, H> {
    private let cop: Cop8<A, B, C, D, E, F, G, H>

    private init(_ cop: Cop8<A, B, C, D, E, F, G, H>) {
        self.cop = cop
    }

    public static func first(_ a: A) -> Coproduct8<A, B, C, D, E, F, G, H> {
        return Coproduct8(.first(a))
    }

    public static func second(_ b: B) -> Coproduct8<A, B, C, D, E, F, G, H> {
        return Coproduct8(.second(b))
    }

    public static func third(_ c: C) -> Coproduct8<A, B, C, D, E, F, G, H> {
        return Coproduct8(.third(c))
    }

    public static func fourth(_ d: D) -> Coproduct8<A, B, C, D, E, F, G, H> {
        return Coproduct8(.fourth(d))
    }

    public static func fifth(_ e: E) -> Coproduct8<A, B, C, D, E, F, G, H> {
        return Coproduct8(.fifth(e))
    }

    public static func sixth(_ f: F) -> Coproduct8<A, B, C, D, E, F, G, H> {
        return Coproduct8(.sixth(f))
    }

    public static func seventh(_ g: G) -> Coproduct8<A, B, C, D, E, F, G, H> {
        return Coproduct8(.seventh(g))
    }

    public static func eighth(_ h: H) -> Coproduct8<A, B, C, D, E, F, G, H> {
        return Coproduct8(.eighth(h))
    }

    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z,
                        _ fc: (C) -> Z,
                        _ fd: (D) -> Z,
                        _ fe: (E) -> Z,
                        _ ff: (F) -> Z,
                        _ fg: (G) -> Z,
                        _ fh: (H) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        case let .third(c): return fc(c)
        case let .fourth(d): return fd(d)
        case let .fifth(e): return fe(e)
        case let .sixth(f): return ff(f)
        case let .seventh(g): return fg(g)
        case let .eighth(h): return fh(h)
        }
    }

    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var fifth: Option<E> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var sixth: Option<F> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    public var seventh: Option<G> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

    public var eighth: Option<H> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some)
    }
}

private enum Cop8<A, B, C, D, E, F, G, H> {
    case first(A)
    case second(B)
    case third(C)
    case fourth(D)
    case fifth(E)
    case sixth(F)
    case seventh(G)
    case eighth(H)
}
