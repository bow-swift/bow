import Foundation

public class ForFold {}
public typealias FoldOf<S, A> = Kind2<ForFold, S, A>
public typealias FoldPartial<S> = Kind<ForFold, S>

open class Fold<S, A> : FoldOf<S, A> {
    
    public static func identity() -> Fold<A, A> {
        return Iso<A, A>.identity().asFold()
    }
    
    public static func codiagonal() -> Fold<Either<S, S>, S> {
        return CodiagonalFold<S>()
    }
    
    public static func select(_ predicate : @escaping (S) -> Bool) -> Fold<S, S> {
        return SelectFold<S>(predicate: predicate)
    }
    
    public static func void() -> Fold<S, A> {
        return Optional<S, A>.void().asFold()
    }
    
    public static func from<FoldableType, F>(foldable : FoldableType) -> Fold<Kind<F, S>, S> where FoldableType : Foldable, FoldableType.F == F {
        return FoldableFold(foldable: foldable)
    }
    
    public static func +<C>(lhs : Fold<S, A>, rhs : Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : Fold<S, A>, rhs : Iso<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : Fold<S, A>, rhs : Getter<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : Fold<S, A>, rhs : Lens<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : Fold<S, A>, rhs : Prism<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : Fold<S, A>, rhs : Optional<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    public static func +<C>(lhs : Fold<S, A>, rhs : Traversal<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    open func foldMap<Mono, R>(_ monoid : Mono, _ s : S, _ f : @escaping (A) -> R) -> R where Mono : Monoid, Mono.A == R {
        fatalError("foldMap must be overriden in subclasses")
    }
    
    public func size(_ s : S) -> Int {
        return foldMap(Int.sumMonoid, s, constant(1))
    }
    
    public func forAll(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return foldMap(Bool.andMonoid, s, predicate)
    }
    
    public func isEmpty(_ s : S) -> Bool {
        return foldMap(Bool.andMonoid, s, constant(false))
    }
    
    public func nonEmpty(_ s : S) -> Bool {
        return !isEmpty(s)
    }
    
    public func headMaybe(_ s : S) -> Maybe<A> {
        return foldMap(FirstMaybeMonoid<A>(), s, { a in Const<Maybe<A>, First>(Maybe.some(a)) }).value
    }
    
    public func lastMaybe(_ s : S) -> Maybe<A> {
        return foldMap(LastMaybeMonoid<A>(), s, { a in Const<Maybe<A>, Last>(Maybe.some(a)) }).value
    }
    
    public func fold<Mono>(_ monoid : Mono, _ s : S) -> A where Mono : Monoid, Mono.A == A {
        return foldMap(monoid, s, id)
    }
    
    public func combineAll<Mono>(_ monoid : Mono, _ s : S) -> A where Mono : Monoid, Mono.A == A {
        return foldMap(monoid, s, id)
    }
    
    public func getAll(_ s : S) -> ListK<A> {
        return foldMap(ListK<A>.monoid(), s, ListK<A>.pure).fix()
    }
    
    public func choice<C>(_ other : Fold<C, A>) -> Fold<Either<S, C>, A> {
        return ChoiceFold(first: self, second: other)
    }
    
    public func left<C>() -> Fold<Either<S, C>, Either<A, C>> {
        return LeftFold(fold: self)
    }
    
    public func right<C>() -> Fold<Either<C, S>, Either<C, A>> {
        return RightFold(fold: self)
    }
    
    public func compose<C>(_ other : Fold<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other)
    }
    
    public func compose<C>(_ other : Iso<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }
    
    public func compose<C>(_ other : Getter<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }
    
    public func compose<C>(_ other : Lens<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }
    
    public func compose<C>(_ other : Prism<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }
    
    public func compose<C>(_ other : Optional<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }
    
    public func compose<C>(_ other : Traversal<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }
    
    public func find(_ s : S, _ predicate : @escaping (A) -> Bool) -> Maybe<A> {
        return foldMap(FirstMaybeMonoid<A>(), s, { a in predicate(a) ? Const<Maybe<A>, First>(Maybe.some(a)) : Const(Maybe.none()) }).value
    }
    
    public func exists(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return find(s, predicate).fold(constant(false), constant(true))
    }
}

fileprivate class CodiagonalFold<S> : Fold<Either<S, S>, S> {
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: Either<S, S>, _ f: @escaping (S) -> R) -> R where Mono : Monoid, R == Mono.A {
        return s.fold(f, f)
    }
}

fileprivate class SelectFold<S> : Fold<S, S> {
    private let predicate : (S) -> Bool
    
    init(predicate : @escaping (S) -> Bool) {
        self.predicate = predicate
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: S, _ f: @escaping (S) -> R) -> R where Mono : Monoid, R == Mono.A {
        return predicate(s) ? f(s) : monoid.empty
    }
}

fileprivate class FoldableFold<FoldableType, F, S> : Fold<Kind<F, S>, S> where FoldableType : Foldable, FoldableType.F == F {
    private let foldable : FoldableType
    
    init(foldable : FoldableType) {
        self.foldable = foldable
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: Kind<F, S>, _ f: @escaping (S) -> R) -> R where Mono : Monoid, R == Mono.A {
        return foldable.foldMap(monoid, s, f)
    }
}

fileprivate class ChoiceFold<S, C, A> : Fold<Either<S, C>, A> {
    private let first : Fold<S, A>
    private let second : Fold<C, A>
    
    init(first : Fold<S, A>, second : Fold<C, A>) {
        self.first = first
        self.second = second
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ esc: Either<S, C>, _ f: @escaping (A) -> R) -> R where Mono : Monoid, R == Mono.A {
        return esc.fold({ s in first.foldMap(monoid, s, f)},
                      { c in second.foldMap(monoid, c, f)})
    }
}

fileprivate class LeftFold<S, C, A> : Fold<Either<S, C>, Either<A, C>> {
    private let fold : Fold<S, A>
    
    init(fold : Fold<S, A>) {
        self.fold = fold
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: Either<S, C>, _ f: @escaping (Either<A, C>) -> R) -> R where Mono : Monoid, R == Mono.A {
        return s.fold({ a1 in fold.foldMap(monoid, a1, { b in f(Either.left(b)) }) },
                      { c in f(Either.right(c)) })
    }
}

fileprivate class RightFold<S, C, A> : Fold<Either<C, S>, Either<C, A>> {
    private let fold : Fold<S, A>
    
    init(fold : Fold<S, A>) {
        self.fold = fold
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: Either<C, S>, _ f: @escaping (Either<C, A>) -> R) -> R where Mono : Monoid, R == Mono.A {
        return s.fold({ c in f(Either.left(c)) },
                      { a1 in fold.foldMap(monoid, a1, { b in f(Either.right(b)) }) })
    }
}

fileprivate class ComposeFold<S, C, A> : Fold<S, C> {
    private let first : Fold<S, A>
    private let second : Fold<A, C>
    
    init(first : Fold<S, A>, second : Fold<A, C>) {
        self.first = first
        self.second = second
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: S, _ f: @escaping (C) -> R) -> R where Mono : Monoid, R == Mono.A {
        return self.first.foldMap(monoid, s, { c in self.second.foldMap(monoid, c, f) })
    }
}
