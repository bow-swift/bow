import Foundation

public class ForFold {}
public typealias FoldOf<S, A> = Kind2<ForFold, S, A>
public typealias FoldPartial<S> = Kind<ForFold, S>

public class Fold<S, A> : FoldOf<S, A> {
    
    public static func create<Mono, R>(foldMap : @escaping (Mono, S, @escaping (A) -> R) -> R) -> Fold<S, A> where Mono : Monoid, Mono.A == R {
        return FoldDefault<S, A, Mono, R>(foldMap: foldMap)
    }
    
    public func foldMap<Mono, R>(_ monoid : Mono, _ s : S, _ f : @escaping (A) -> R) -> R where Mono : Monoid, Mono.A == R {
        fatalError()
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

fileprivate class FoldDefault<S, A, Mono, R> : Fold<S, A> where Mono : Monoid, Mono.A == R {
    private let foldMapFunc : (Mono, S, @escaping (A) -> R) -> R
    
    fileprivate init(foldMap : @escaping (Mono, S, @escaping (A) -> R) -> R) {
        self.foldMapFunc = foldMap
    }
    
    override public func foldMap<Mono2, R2>(_ monoid: Mono2, _ s: S, _ f: @escaping (A) -> R2) -> R2 where Mono2 : Monoid, R2 == Mono2.A {
        return self.foldMapFunc(monoid as! Mono, s, { a in f(a) as! R }) as! R2
    }
}
