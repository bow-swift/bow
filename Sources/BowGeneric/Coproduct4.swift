import Bow

public final class ForCoproduct4 {}
public typealias Coproduct4Of<A, B, C, D> = Kind4<ForCoproduct4, A, B, C, D>

public final class Coproduct4<A, B, C, D>: Coproduct4Of<A, B, C, D> {
    private let cop: Cop4<A, B, C, D>

    private init(_ cop: Cop4<A, B, C, D>) {
        self.cop = cop
    }

    public static func first(_ a: A) -> Coproduct4<A, B, C, D> {
        return Coproduct4(.first(a))
    }

    public static func second(_ b: B) -> Coproduct4<A, B, C, D> {
        return Coproduct4(.second(b))
    }

    public static func third(_ c: C) -> Coproduct4<A, B, C, D> {
        return Coproduct4(.third(c))
    }

    public static func fourth(_ d: D) -> Coproduct4<A, B, C, D> {
        return Coproduct4(.fourth(d))
    }

    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z,
                        _ fc: (C) -> Z,
                        _ fd: (D) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        case let .third(c): return fc(c)
        case let .fourth(d): return fd(d)
        }
    }

    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()), constant(Option.none()), constant(Option.none()))
    }

    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some, constant(Option.none()), constant(Option.none()))
    }

    public var third: Option<C> {
        return fold(constant(Option.none()), constant(Option.none()), Option.some, constant(Option.none()))
    }

    public var fourth: Option<D> {
        return fold(constant(Option.none()), constant(Option.none()), constant(Option.none()), Option.some)
    }
}

private enum Cop4<A, B, C, D> {
    case first(A)
    case second(B)
    case third(C)
    case fourth(D)
}
