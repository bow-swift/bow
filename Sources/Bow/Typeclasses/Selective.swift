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

// MARK: Syntax for Selective

public extension Kind where F: Selective {
    public func select<AA, B>(_ f: Kind<F, (AA) -> B>) -> Kind<F, B> where A == Either<AA, B> {
        return F.select(self, f)
    }

    public func branch<AA, B, C>(_ fa: Kind<F, (AA) -> C>, _ fb: Kind<F, (B) -> C>) -> Kind<F, C> where A == Either<AA, B> {
        return F.branch(self, fa, fb)
    }

    public static func fromOptionS(_ x: Kind<F, A>, _ mx: Kind<F, Option<A>>) -> Kind<F, A> {
        return F.fromOptionS(x, mx)
    }
}

public extension Kind where F: Selective, A == Bool {
    public static func whenS(_ cond: Kind<F, Bool>, _ f: Kind<F, ()>) -> Kind<F, ()> {
        return F.whenS(cond, f)
    }

    public static func ifS<A>(_ x: Kind<F, Bool>, _ t: Kind<F, A>, _ e: Kind<F, A>) -> Kind<F, A> {
        return F.ifS(x, t, e)
    }

    public static func orS(_ x: Kind<F, Bool>, _ y: Kind<F, Bool>) -> Kind<F, Bool> {
        return F.orS(x, y)
    }

    public static func andS(_ x: Kind<F, Bool>, _ y: Kind<F, Bool>) -> Kind<F, Bool> {
        return F.andS(x, y)
    }

    public static func whileS(_ x: Kind<F, Bool>) -> Eval<Kind<F, ()>> {
        return F.whileS(x)
    }
}

public extension ArrayK {
    public func anyS<F: Selective>(_ p: @escaping (A) -> Kind<F, Bool>) -> Kind<F, Bool> {
        return F.anyS(p, self)
    }

    public func allS<F: Selective>(_ p: @escaping (A) -> Kind<F, Bool>) -> Kind<F, Bool> {
        return F.anyS(p, self)
    }
}
