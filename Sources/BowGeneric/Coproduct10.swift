import Bow

public final class ForCoproduct10 {}
public typealias Coproduct10Of<A, B, C, D, E, F, G, H, I, J> = Kind10<ForCoproduct10, A, B, C, D, E, F, G, H, I, J>

public final class Coproduct10<A, B, C, D, E, F, G, H, I, J>: Coproduct10Of<A, B, C, D, E, F, G, H, I, J> {
    private let cop: Cop10<A, B, C, D, E, F, G, H, I, J>

    private init(_ cop: Cop10<A, B, C, D, E, F, G, H, I, J>) {
        self.cop = cop
    }

    public static func first(_ a: A) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.first(a))
    }

    public static func second(_ b: B) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.second(b))
    }

    public static func third(_ c: C) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.third(c))
    }

    public static func fourth(_ d: D) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.fourth(d))
    }

    public static func fifth(_ e: E) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.fifth(e))
    }

    public static func sixth(_ f: F) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.sixth(f))
    }

    public static func seventh(_ g: G) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.seventh(g))
    }

    public static func eighth(_ h: H) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.eighth(h))
    }

    public static func ninth(_ i: I) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.ninth(i))
    }

    public static func tenth(_ j: J) -> Coproduct10<A, B, C, D, E, F, G, H, I, J> {
        return Coproduct10(.tenth(j))
    }

    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z,
                        _ fc: (C) -> Z,
                        _ fd: (D) -> Z,
                        _ fe: (E) -> Z,
                        _ ff: (F) -> Z,
                        _ fg: (G) -> Z,
                        _ fh: (H) -> Z,
                        _ fi: (I) -> Z,
                        _ fj: (J) -> Z) -> Z {
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
        case let .tenth(j): return fj(j)
        }
    }

    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var fifth: Option<E> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var sixth: Option<F> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var seventh: Option<G> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var eighth: Option<H> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    public var ninth: Option<I> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

    public var tenth: Option<J> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some)
    }
}

private enum Cop10<A, B, C, D, E, F, G, H, I, J> {
    case first(A)
    case second(B)
    case third(C)
    case fourth(D)
    case fifth(E)
    case sixth(F)
    case seventh(G)
    case eighth(H)
    case ninth(I)
    case tenth(J)
}
