import Foundation

public class ForPTraversal {}
public typealias PTraversalOf<S, T, A, B> = Kind4<ForPTraversal, S, T, A, B>
public typealias PTraversalPartial<S, T, A> = Kind3<ForPTraversal, S, T, A>

public typealias Traversal<S, A> = PTraversal<S, S, A, A>
public typealias ForTraversal = ForPTraversal
public typealias TraversalOf<S, A> = PTraversalOf<S, S, A, A>
public typealias TraversalPartial<S> = Kind<ForPTraversal, S>

open class PTraversal<S, T, A, B> : PTraversalOf<S, T, A, B> {

    open func modifyF<Appl, F>(_ applicative : Appl, _ s : S, _ f : @escaping (A) -> Kind<F, B>) -> Kind<F, T> where Appl : Applicative, Appl.F == F {
        fatalError("mofifyF must be implemented in subclasses")
    }

    func foldMap<Mono, R>(_ monoid : Mono, _ s : S, _ f : @escaping (A) -> R) -> R where Mono : Monoid, Mono.A == R {
        return Const.fix(self.modifyF(Const<R, B>.applicative(monoid), s, { b in Const<R, B>(f(b)) })).value
    }
    
    func fold<Mono>(_ monoid : Mono, _ s : S) -> A where Mono : Monoid, Mono.A == A {
        return foldMap(monoid, s, id)
    }
    
    func combineAll<Mono>(_ monoid : Mono, _ s : S) -> A where Mono : Monoid, Mono.A == A {
        return fold(monoid, s)
    }
    
    func getAll(_ s : S) -> ListK<A> {
        return foldMap(ListK.monoid(), s, { a in ListK([a]) }).fix()
    }
    
    func set(_ s : S, _ b : B) -> T {
        return modify(s, constF(b))
    }
    
    func size(_ s : S) -> Int {
        return foldMap(Int.sumMonoid, s, constF(1))
    }
    
    func isEmpty(_ s : S) -> Bool {
        return foldMap(Bool.andMonoid, s, constF(false))
    }
    
    func nonEmpty(_ s : S) -> Bool {
        return !isEmpty(s)
    }
    
    func headMaybe(_ s : S) -> Maybe<A> {
        return foldMap(FirstMaybeMonoid<A>(), s, { b in Const(Maybe.some(b)) }).value
    }
    
    func lastMaybe(_ s : S) -> Maybe<A> {
        return foldMap(LastMaybeMonoid<A>(), s, { b in Const(Maybe.some(b)) }).value
    }
    
    func choice<U, V>(_ other : PTraversal<U, V, A, B>) -> PTraversal<Either<S, U>, Either<T, V>, A, B> {
        return ChoiceTraversal(first: self, second: other)
    }
    
    func asSetter() -> PSetter<S, T, A, B> {
        return PSetter(modify: { f in { s in self.modify(s, f) } })
    }
    
    func asFold() -> Fold<S, A> {
        return TraversalFold(traversal: self)
    }
    
    func find(_ s : S, _ predicate : @escaping (A) -> Bool) -> Maybe<A> {
        return foldMap(FirstMaybeMonoid(), s, { a in
            predicate(a) ? Const(Maybe.some(a)) : Const(Maybe.none())
        }).value
    }
    
    func modify(_ s : S, _ f : @escaping (A) -> B) -> T {
        return modifyF(Id<A>.applicative(), s, { a in Id.pure(f(a)) }).fix().value
    }
    
    func exists(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return find(s, predicate).fold(constF(false), constF(true))
    }
    
    func forall(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return foldMap(Bool.andMonoid, s, predicate)
    }
}

fileprivate class ChoiceTraversal<S, T, U, V, A, B> : PTraversal<Either<S, U>, Either<T, V>, A, B> {
    private let first : PTraversal<S, T, A, B>
    private let second : PTraversal<U, V, A, B>
    
    init(first : PTraversal<S, T, A, B>, second : PTraversal<U, V, A, B>) {
        self.first = first
        self.second = second
    }
    
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: Either<S, U>, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, Either<T, V>> where Appl : Applicative, F == Appl.F {
        return s.fold({ s in applicative.map(first.modifyF(applicative, s, f), { t in
                        Either.left(t) }) },
                      { u in applicative.map(second.modifyF(applicative, u, f), { v in
                        Either.right(v) }) })
    }
}

fileprivate class TraversalFold<S, T, A, B> : Fold<S, A> {
    private let traversal : PTraversal<S, T, A, B>
    
    init(traversal : PTraversal<S, T, A, B>) {
        self.traversal = traversal
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: S, _ f: @escaping (A) -> R) -> R where Mono : Monoid, R == Mono.A {
        return traversal.foldMap(monoid, s, f)
    }
}
