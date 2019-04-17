import Bow

public final class ForCoproduct9 {}
public typealias Coproduct9Of<A, B, C, D, E, F, G, H, I> = Kind9<ForCoproduct9, A, B, C, D, E, F, G, H, I>

public final class Coproduct9<A, B, C, D, E, F, G, H, I>: Coproduct9Of<A, B, C, D, E, F, G, H, I> {
    private let cop: Cop9<A, B, C, D, E, F, G, H, I>

    private init(_ cop: Cop9<A, B, C, D, E, F, G, H, I>) {
        self.cop = cop
    }

    public static func first(_ a: A) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.first(a))
    }

    public static func second(_ b: B) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.second(b))
    }

    public static func third(_ c: C) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.third(c))
    }

    public static func fourth(_ d: D) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.fourth(d))
    }

    public static func fifth(_ e: E) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.fifth(e))
    }

    public static func sixth(_ f: F) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.sixth(f))
    }

    public static func seventh(_ g: G) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.seventh(g))
    }

    public static func eighth(_ h: H) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.eighth(h))
    }

    public static func ninth(_ i: I) -> Coproduct9<A, B, C, D, E, F, G, H, I> {
        return Coproduct9(.ninth(i))
    }

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

    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var fifth: Option<E> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var sixth: Option<F> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var seventh: Option<G> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    public var eighth: Option<H> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

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
