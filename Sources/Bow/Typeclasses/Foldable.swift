import Foundation

public protocol Foldable {
    static func foldLeft<A, B>(_ fa: Kind<Self, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B
    static func foldRight<A, B>(_ fa: Kind<Self, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B>
}

public extension Foldable {
    public static func fold<A: Monoid>(_ fa : Kind<Self, A>) -> A {
        return foldLeft(fa, A.empty(), { acc, a in acc.combine(a) })
    }
    
    public static func reduceLeftToOption<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (B, A) -> B) -> Option<B> {
        return Option.fix(foldLeft(fa, Option.empty, { option, a in
            Option.fix(option).fold(constant(Option.some(f(a))),
                                    { b in Option.some(g(b, a)) })
        }))
    }
    
    public static func reduceRightToOption<A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<Option<B>> {
        return Eval.fix(foldRight(fa, Eval.now(Option.empty), { a, lb in
            Eval.fix(Eval.fix(lb).flatMap({ option in
                Option.fix(option).fold({ Eval.later({ Option.some(f(a)) }) },
                                        { b in Eval.fix(g(a, Eval.now(b)).map(Option.some)) })
            }))
        }).map { x in Option.fix(x) })
    }
    
    public static func reduceLeftOption<A>(_ fa: Kind<Self, A>, _ f: @escaping (A, A) -> A) -> Option<A> {
        return reduceLeftToOption(fa, id, f)
    }
    
    public static func reduceRightOption<A>(_ fa: Kind<Self, A>, _ f: @escaping (A, Eval<A>) -> Eval<A>) -> Eval<Option<A>> {
        return reduceRightToOption(fa, id, f)
    }
    
    public static func combineAll<A: Monoid>(_ fa: Kind<Self, A>) -> A {
        return fold(fa)
    }
    
    public static func foldMap<A, B: Monoid>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> B) -> B {
        return foldLeft(fa, B.empty(), { b, a in b.combine(f(a)) })
    }
    
    public static func traverse_<G: Applicative, A, B>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Unit> {
        return foldRight(fa, Eval.always({ G.pure(unit) }), { a, acc in
            G.map2Eval(f(a), acc, { _, _ in unit })
        }).value()
    }
    
    public static func sequence_<G: Applicative, A>(_ fga: Kind<Self, Kind<G, A>>) -> Kind<G, Unit> {
        return traverse_(fga, id)
    }
    
    public static func find<A>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Bool) -> Option<A> {
        return foldRight(fa, Eval.now(Option.none()), { a, lb in
            f(a) ? Eval.now(Option.some(a)) : lb
        }).value()
    }
    
    public static func exists<A>(_ fa: Kind<Self, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        return foldRight(fa, Eval<Bool>.False, { a, lb in
            predicate(a) ? Eval<Bool>.True : lb
        }).value()
    }
    
    public static func forall<A>(_ fa: Kind<Self, A>, _ predicate: @escaping (A) -> Bool) -> Bool {
        return foldRight(fa, Eval<Bool>.True, { a, lb in
            predicate(a) ? lb : Eval<Bool>.False
        }).value()
    }
    
    public static func isEmpty<A>(_ fa: Kind<Self, A>) -> Bool {
        return foldRight(fa, Eval<Bool>.True, { _, _ in Eval<Bool>.False }).value()
    }
    
    public static func nonEmpty<A>(_ fa: Kind<Self, A>) -> Bool {
        return !isEmpty(fa)
    }
    
    public static func foldM<G: Monad, A, B>(_ fa: Kind<Self, A>, _ b: B, _ f: @escaping (B, A) -> Kind<G, B>) -> Kind<G, B> {
        return foldLeft(fa, G.pure(b), { gb, a in G.flatMap(gb, { b in f(b, a) }) })
    }
    
    public static func foldMapM<G: Monad, A, B: Monoid>(_ fa: Kind<Self, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, B> {
        return foldM(fa, B.empty(), { b, a in G.map(f(a), { bb in b.combine(bb) }) })
    }
    
    public static func get<A>(_ fa: Kind<Self, A>, _ index: Int64) -> Option<A> {
        return Either.fix(foldM(fa, Int64(0), { i, a in
            (i == index) ?
                Either<A, Int64>.left(a) :
                Either<A, Int64>.right(i + 1)
        })).fold(Option<A>.some,
                 constant(Option<A>.none()))
    }
    
    public static func count<A>(_ fa: Kind<Self, A>) -> Int64 {
        return foldMap(fa, constant(1))
    }
}

// MARK: Syntax for Foldable

public extension Kind where F: Foldable {
    public func foldLeft<B>(_ b: B, _ f: @escaping (B, A) -> B) -> B {
        return F.foldLeft(self, b, f)
    }

    public func foldRight<B>(_ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return F.foldRight(self, b, f)
    }

    public func reduceLeftToOption<B>(_ f: @escaping (A) -> B, _ g: @escaping (B, A) -> B) -> Option<B> {
        return F.reduceLeftToOption(self, f, g)
    }

    public func reduceRightToOption<B>(_ f: @escaping (A) -> B, _ g: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<Option<B>> {
        return F.reduceRightToOption(self, f, g)
    }

    public func reduceLeftOption(_ f: @escaping (A, A) -> A) -> Option<A> {
        return F.reduceLeftOption(self, f)
    }

    public func reduceRightOption(_ f: @escaping (A, Eval<A>) -> Eval<A>) -> Eval<Option<A>> {
        return F.reduceRightOption(self, f)
    }

    public func foldMap<B: Monoid>(_ f: @escaping (A) -> B) -> B {
        return F.foldMap(self, f)
    }

    public func traverse_<G: Applicative, B>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Unit> {
        return F.traverse_(self, f)
    }

    public static func sequence_<G: Applicative>(_ fga: Kind<F, Kind<G, A>>) -> Kind<G, Unit> {
        return F.sequence_(fga)
    }

    public func find(_ f: @escaping (A) -> Bool) -> Option<A> {
        return F.find(self, f)
    }

    public func exists(_ predicate: @escaping (A) -> Bool) -> Bool {
        return F.exists(self, predicate)
    }

    public func forall(_ predicate: @escaping (A) -> Bool) -> Bool {
        return F.forall(self, predicate)
    }

    public var isEmpty: Bool {
        return F.isEmpty(self)
    }

    public var nonEmpty: Bool {
        return F.nonEmpty(self)
    }

    public func foldM<G: Monad, B>(_ b: B, _ f: @escaping (B, A) -> Kind<G, B>) -> Kind<G, B> {
        return F.foldM(self, b, f)
    }

    public func foldMapM<G: Monad, B: Monoid>(_ f: @escaping (A) -> Kind<G, B>) -> Kind<G, B> {
        return F.foldMapM(self, f)
    }

    public func get(_ index: Int64) -> Option<A> {
        return F.get(self, index)
    }
}

public extension Kind where F: Foldable, A: Monoid {
    public func fold() -> A {
        return F.fold(self)
    }

    public func combineAll() -> A {
        return F.combineAll(self)
    }

    public var count: Int64 {
        return F.count(self)
    }
}
