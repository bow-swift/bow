import Foundation

public class ForFold {}
public typealias FoldOf<S, A> = Kind2<ForFold, S, A>
public typealias FoldPartial<S> = Kind<ForFold, S>

open class Fold<S, A> : FoldOf<S, A> {
    
    public static func codiagonal() -> Fold<Either<S, S>, S> {
        return CodiagonalFold<S>()
    }
    
    public static func select(_ predicate : @escaping (S) -> Bool) -> Fold<S, S> {
        return SelectFold<S>(predicate: predicate)
    }
    
    public static func from<FoldableType, F>(foldable : FoldableType) -> Fold<Kind<F, S>, S> where FoldableType : Foldable, FoldableType.F == F {
        return FoldableFold(foldable: foldable)
    }
    
    open func foldMap<Mono, R>(_ monoid : Mono, _ s : S, _ f : @escaping (A) -> R) -> R where Mono : Monoid, Mono.A == R {
        fatalError("foldMap must be overriden in subclasses")
    }
    
    public func size(_ s : S) -> Int {
        return foldMap(Int.sumMonoid, s, constF(1))
    }
    
    public func forAll(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return foldMap(Bool.andMonoid, s, predicate)
    }
    
    public func isEmpty(_ s : S) -> Bool {
        return foldMap(Bool.andMonoid, s, constF(false))
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
    
    public func find(_ s : S, _ predicate : @escaping (A) -> Bool) -> Maybe<A> {
        return foldMap(FirstMaybeMonoid<A>(), s, { a in predicate(a) ? Const<Maybe<A>, First>(Maybe.some(a)) : Const(Maybe.none()) }).value
    }
    
    public func exists(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return find(s, predicate).fold(constF(false), constF(true))
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
