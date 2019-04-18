import Bow

public final class ForCoproduct2 {}
public typealias Coproduct2Of<A, B> = Kind2<ForCoproduct2, A, B>

public final class Coproduct2<A, B>: Coproduct2Of<A, B> {
    private let cop: Cop2<A, B>

    private init(_ cop: Cop2<A, B>) {
        self.cop = cop
    }

    public static func first(_ a: A) -> Coproduct2<A, B> {
        return Coproduct2(.first(a))
    }

    public static func second(_ b: B) -> Coproduct2<A, B> {
        return Coproduct2(.second(b))
    }


    public func fold<Z>(_ fa: (A) -> Z,
                        _ fb: (B) -> Z) -> Z {
        switch cop {
        case let .first(a): return fa(a)
        case let .second(b): return fb(b)
        }
    }

    public var first: Option<A> {
        return fold(Option.some, constant(Option.none()))
    }

    public var second: Option<B> {
        return fold(constant(Option.none()), Option.some)
    }
}

private enum Cop2<A, B> {
    case first(A)
    case second(B)
}
