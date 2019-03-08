import Foundation

public protocol Selective: Applicative {
    static func select<A, B>(_ fab: Kind<Self, Either<A, B>>, _ f: Kind<Self, (A) -> B>) -> Kind<Self, B>
}

// MARK: Related functions

public extension Selective {
    private static func selector(_ x: Kind<Self, Bool>) -> Kind<Self, Either<(), ()>> {
        return map(x, { flag in flag ? Either.left(()) : Either.right(()) })
    }

    public static func whenS(_ cond: Kind<Self, Bool>, _ f: Kind<Self, ()>) -> Kind<Self, ()> {
        let effect = map(f) { ff in { (_: ()) in } }
        return select(selector(cond), effect)
    }

    public static func branch<A, B, C>(_ fab: Kind<Self, Either<A, B>>, _ fa: Kind<Self, (A) -> C>, _ fb: Kind<Self, (B) -> C>) -> Kind<Self, C> {
        let x = map(fab) { eab in Either.fix(eab.map(Either<B, C>.left)) }
        let y = map(fa) { f in { a in Either<B, C>.right(f(a)) } }
        return select(select(x, y), fb)
    }

    public static func ifS<A>(_ x: Kind<Self, Bool>, _ t: Kind<Self, A>, _ e: Kind<Self, A>) -> Kind<Self, A> {
        return branch(selector(x), map(t, constant), map(e, constant))
    }

    public static func orS(_ x: Kind<Self, Bool>, _ y: Kind<Self, Bool>) -> Kind<Self, Bool> {
        return ifS(x, pure(true), y)
    }

    public static func andS(_ x: Kind<Self, Bool>, _ y: Kind<Self, Bool>) -> Kind<Self, Bool> {
        return ifS(x, y, pure(false))
    }

    public static func fromOptionS<A>(_ x: Kind<Self, A>, _ mx: Kind<Self, Option<A>>) -> Kind<Self, A> {
        let s = map(mx) { a in Option.fix(a.map(Either<(), A>.right)).getOrElse(Either.left(())) }
        return select(s, map(x, constant))
    }

    public static func anyS<A>(_ p: @escaping (A) -> Kind<Self, Bool>, _ array: ArrayK<A>) -> Kind<Self, Bool> {
        return array.foldRight(Eval.now(pure(false))) { a, b in Eval.later { orS(p(a), b.value()) } }.value()
    }

    public static func allS<A>(_ p: @escaping (A) -> Kind<Self, Bool>, _ array: ArrayK<A>) -> Kind<Self, Bool> {
        return array.foldRight(Eval.now(pure(true))) { a, b in Eval.later { andS(p(a), b.value()) } }.value()
    }

    public static func whileS(_ x: Kind<Self, Bool>) -> Eval<Kind<Self, ()>> {
        return Eval.later { whenS(x, whileS(x).value()) }
    }
}
