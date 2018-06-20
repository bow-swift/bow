import Foundation

public class ForGetter {}
public typealias GetterOf<S, A> = Kind2<ForGetter, S, A>
public typealias GetterPartial<S> = Kind<ForGetter, S>

public class Getter<S, A> : GetterOf<S, A> {
    private let getFunc : (S) -> A
    
    public static func +<C>(lhs : Getter<S, A>, rhs : Getter<A, C>) -> Getter<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : Getter<S, A>, rhs : Lens<A, C>) -> Getter<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : Getter<S, A>, rhs : Iso<A, C>) -> Getter<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : Getter<S, A>, rhs : Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func identity() -> Getter<S, S> {
        return Iso<S, S>.identity().asGetter()
    }
    
    public static func codiagonal() -> Getter<Either<S, S>, S> {
        return Getter<Either<S, S>, S>(get: { either in
            either.fold(id, id)
        })
    }
    
    public init(get : @escaping (S) -> A) {
        self.getFunc = get
    }
    
    public func get(_ s : S) -> A {
        return getFunc(s)
    }
    
    public func choice<C>(_ other : Getter<C, A>) -> Getter<Either<S, C>, A> {
        return Getter<Either<S, C>, A>(get: { either in
            either.fold(self.get, other.get)
        })
    }
    
    public func split<C, D>(_ other : Getter<C, D>) -> Getter<(S, C), (A, D)> {
        return Getter<(S, C), (A, D)>(get: { (s, c) in (self.get(s), other.get(c)) })
    }
    
    public func zip<C>(_ other : Getter<S, C>) -> Getter<S, (A, C)> {
        return Getter<S, (A, C)>(get: { s in (self.get(s), other.get(s)) })
    }
    
    public func first<C>() -> Getter<(S, C), (A, C)> {
        return Getter<(S, C), (A, C)>(get: { (s, c) in (self.get(s), c) })
    }
    
    public func second<C>() -> Getter<(C, S), (C, A)> {
        return Getter<(C, S), (C, A)>(get: { (c, s) in (c, self.get(s)) })
    }
    
    public func left<C>() -> Getter<Either<S, C>, Either<A, C>> {
        return Getter<Either<S, C>, Either<A, C>>(get: { either in
            either.bimap(self.get, id)
        })
    }
    
    public func right<C>() -> Getter<Either<C, S>, Either<C, A>> {
        return Getter<Either<C, S>, Either<C, A>>(get: { either in
            either.map(self.get)
        })
    }
    
    public func compose<C>(_ other : Getter<A, C>) -> Getter<S, C> {
        return Getter<S, C>(get: other.get <<< self.get)
    }
    
    public func compose<C>(_ other : Lens<A, C>) -> Getter<S, C> {
        return Getter<S, C>(get: other.get <<< self.get)
    }
    
    public func compose<C>(_ other : Iso<A, C>) -> Getter<S, C> {
        return Getter<S, C>(get: other.get <<< self.get)
    }
    
    public func compose<C>(_ other : Fold<A, C>) -> Fold<S, C> {
        return self.asFold().compose(other)
    }
    
    public func asFold() -> Fold<S, A> {
        return GetterFold(getter: self)
    }
    
    public func find(_ s : S, _ predicate : (A) -> Bool) -> Maybe<A> {
        let a = get(s)
        if predicate(a) {
            return Maybe.some(a)
        } else {
            return Maybe.none()
        }
    }
    
    public func exists(_ s : S, _ predicate : (A) -> Bool) -> Bool {
        return predicate(get(s))
    }
}

fileprivate class GetterFold<S, A> : Fold<S, A> {
    private let getter : Getter<S, A>
    
    init(getter : Getter<S, A>) {
        self.getter = getter
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: S, _ f: @escaping (A) -> R) -> R where Mono : Monoid, R == Mono.A {
        return f(getter.get(s))
    }
}
