import Foundation

public protocol Foldable : Typeclass {
    associatedtype F
    
    func foldL<A, B>(_ fa : Kind<F, A>, _ b : B, _ f : @escaping (B, A) -> B) -> B
    func foldR<A, B>(_ fa : Kind<F, A>, _ b : Eval<B>, _ f : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B>
}

public extension Foldable {
    public func fold<A, Mono>(_ monoid : Mono, _ fa : Kind<F, A>) -> A where Mono : Monoid, Mono.A == A {
        return foldL(fa, monoid.empty, { acc, a in monoid.combine(acc, a) })
    }
    
    public func reduceLeftToMaybe<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> B, _ g : @escaping(B, A) -> B) -> Maybe<B> {
        return foldL(fa, Maybe.empty(), { maybe, a in
            maybe.fold(constant(Maybe<B>.some(f(a))),
                       { b in Maybe<B>.some(g(b, a)) })
        })
    }
    
    public func reduceRightToMaybe<A, B>(_ fa : Kind<F, A>, _ f : @escaping (A) -> B, _ g : @escaping (A, Eval<B>) -> Eval<B>) -> Eval<Maybe<B>> {
        return foldR(fa, Eval<Maybe<B>>.now(Maybe<B>.empty()), { a, lb in
            lb.flatMap({ maybe in
                maybe.fold({ Eval<Maybe<B>>.later({ Maybe<B>.some(f(a)) }) },
                           { b in g(a, Eval<B>.now(b)).map(Maybe<B>.some) })
            })
        })
    }
    
    public func reduceLeftMaybe<A>(_ fa : Kind<F, A>, _ f : @escaping (A, A) -> A) -> Maybe<A> {
        return reduceLeftToMaybe(fa, id, f)
    }
    
    public func reduceRightMaybe<A>(_ fa : Kind<F, A>, _ f : @escaping (A, Eval<A>) -> Eval<A>) -> Eval<Maybe<A>> {
        return reduceRightToMaybe(fa, id, f)
    }
    
    public func combineAll<A, Mono>(_ monoid : Mono, _ fa : Kind<F, A>) -> A where Mono : Monoid, Mono.A == A {
        return fold(monoid, fa)
    }
    
    public func foldMap<A, B, Mono>(_ monoid : Mono, _ fa : Kind<F, A>, _ f : @escaping (A) -> B) -> B where Mono : Monoid, Mono.A == B {
        return foldL(fa, monoid.empty, { b, a in monoid.combine(b, f(a)) })
    }
    
    public func traverse_<G, A, B, Appl>(_ applicative : Appl, _ fa : Kind<F, A>, _ f : @escaping (A) -> Kind<G, B>) -> Kind<G, Unit> where Appl : Applicative, Appl.F == G {
        return foldR(fa, Eval.always({ applicative.pure(unit) }), { a, acc in
            applicative.map2Eval(f(a), acc, { _, _ in unit })
        }).value()
    }
    
    public func sequence_<G, A, Appl>(_ applicative : Appl, _ fga : Kind<F, Kind<G, A>>) -> Kind<G, Unit> where Appl : Applicative, Appl.F == G {
        return traverse_(applicative, fga, id)
    }
    
    public func find<A>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Bool) -> Maybe<A> {
        return foldR(fa, Eval.now(Maybe.none()), { a, lb in
            f(a) ? Eval.now(Maybe.some(a)) : lb
        }).value()
    }
    
    public func exists<A>(_ fa : Kind<F, A>, _ predicate : @escaping (A) -> Bool) -> Bool {
        return foldR(fa, Eval<Bool>.False, { a, lb in
            predicate(a) ? Eval<Bool>.True : lb
        }).value()
    }
    
    public func forall<A>(_ fa : Kind<F, A>, _ predicate : @escaping (A) -> Bool) -> Bool {
        return foldR(fa, Eval<Bool>.True, { a, lb in
            predicate(a) ? lb : Eval<Bool>.False
        }).value()
    }
    
    public func isEmpty<A>(_ fa : Kind<F, A>) -> Bool {
        return foldR(fa, Eval<Bool>.True, { _, _ in Eval<Bool>.False }).value()
    }
    
    public func nonEmpty<A>(_ fa : Kind<F, A>) -> Bool {
        return !isEmpty(fa)
    }
    
    public func foldM<G, A, B, Mon>(_ fa : Kind<F, A>, _ b : B, _ f : @escaping (B, A) -> Kind<G, B>, _ monad : Mon) -> Kind<G, B> where Mon : Monad, Mon.F == G {
        return foldL(fa, monad.pure(b), { gb, a in monad.flatMap(gb, { b in f(b, a) }) })
    }
    
    public func foldMapM<G, A, B, Mon, Mono>(_ fa : Kind<F, A>, _ f : @escaping (A) -> Kind<G, B>, _ monad : Mon, _ monoid : Mono) -> Kind<G, B> where Mon : Monad, Mon.F == G, Mono : Monoid, Mono.A == B {
        return foldM(fa, monoid.empty, { b, a in monad.map(f(a), { bb in monoid.combine(b, bb) }) }, monad)
    }
    
    public func get<A>(_ fa : Kind<F, A>, _ index : Int64) -> Maybe<A> {
        return (foldM(fa, Int64(0), { i, a in
            (i == index) ? Either<A, Int64>.left(a) : Either<A, Int64>.right(i + 1)
        }, Either<A, Int64>.monad() as EitherMonad<A>) as! Either<A, Int64>)
            .fold(Maybe<A>.some, constant(Maybe<A>.none()))
    }
    
    public func size<A, Mono>(_ monoid : Mono, _ fa : Kind<F, A>) -> Int64 where Mono : Monoid, Mono.A == Int64 {
        return foldMap(monoid, fa, { _ in 1 })
    }
    
}























