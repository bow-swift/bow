import Bow

public final class ForCoproduct3 {}
public typealias Coproduct3Of<A, B, C> = Kind3<ForCoproduct3, A, B, C>

public final class Coproduct3<A, B, C>: Coproduct3Of<A, B, C> {
    private let cop: Cop3<A, B, C>

    private init(_ cop: Cop3<A, B, C>) {
        self.cop = cop
    }

    public static func first(_ a: A) -> Coproduct3<A, B, C> {
        return Coproduct3(.first(a))
    }

    public static func second(_ b: B) -> Coproduct3<A, B, C> {
        return Coproduct3(.second(b))
    }

    public static func third(_ c: C) -> Coproduct3<A, B, C> {
        return Coproduct3(.third(c))
    }

    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z,
                        _ fc: (C) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        case let .third(c): return fc(c)
        }
    }

    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()))
    }

    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()))
    }

    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some)
    }
}

private enum Cop3<A, B, C> {
    case first(A)
    case second(B)
    case third(C)
}
