import Foundation

public class ForPLens {}
public typealias PLensOf<S, T, A, B> = Kind4<ForPLens, S, T, A, B>
public typealias PLensPartial<S, T, A> = Kind3<ForPLens, S, T, A>

public typealias Lens<S, A> = PLens<S, S, A, A>
public typealias ForLens = ForPLens
public typealias LensPartial<S> = Kind<ForLens, S>

public class PLens<S, T, A, B> : PLensOf<S, T, A, B> {
    private let getFunc : (S) -> A
    private let setFunc : (S, B) -> T
    
    public static func +<C, D>(lhs : PLens<S, T, A, B>, rhs : PLens<A, B, C, D>) -> PLens<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PLens<S, T, A, B>, rhs : PIso<A, B, C, D>) -> PLens<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : PLens<S, T, A, B>, rhs : Getter<A, C>) -> Getter<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PLens<S, T, A, B>, rhs : PPrism<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PLens<S, T, A, B>, rhs : POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PLens<S, T, A, B>, rhs : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : PLens<S, T, A, B>, rhs : Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : PLens<S, T, A, B>, rhs : PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func identity() -> Lens<S, S> {
        return Iso<S, S>.identity().asLens()
    }
    
    public static func codiagonal() -> Lens<Either<S, S>, S> {
        return Lens<Either<S, S>, S>(
            get: { ess in ess.fold(id, id) },
            set: { ess, s in ess.bimap(constant(s), constant(s)) })
    }
    
    public init(get : @escaping (S) -> A, set : @escaping (S, B) -> T) {
        self.getFunc = get
        self.setFunc = set
    }
    
    public func get(_ s : S) -> A {
        return getFunc(s)
    }
    
    public func set(_ s : S, _ b : B) -> T {
        return setFunc(s, b)
    }
    
    public func modifyF<Func, F>(_ functor : Func, _ s : S, _ f : @escaping (A) -> Kind<F, B>) -> Kind<F, T> where Func : Functor, Func.F == F {
        return functor.map(f(self.get(s)), { b in self.set(s, b) })
    }
    
    public func liftF<Func, F>(_ functor : Func, _ f : @escaping (A) -> Kind<F, B>) -> (S) -> Kind<F, T> where Func : Functor, Func.F == F {
        return { s in self.modifyF(functor, s, f) }
    }
    
    public func choice<S1, T1>(_ other : PLens<S1, T1, A, B>) -> PLens<Either<S, S1>, Either<T, T1>, A, B> {
        return PLens<Either<S, S1>, Either<T, T1>, A, B>(
            get: { either in either.fold(self.get, other.get) },
            set: { either, b in either.bimap({ s in self.set(s, b) }, { s1 in other.set(s1, b) }) })
    }
    
    public func split<S1, T1, A1, B1>(_ other : PLens<S1, T1, A1, B1>) -> PLens<(S, S1), (T, T1), (A, A1), (B, B1)> {
        return PLens<(S, S1), (T, T1), (A, A1), (B, B1)>(
            get: { (s, s1) in (self.get(s), other.get(s1)) },
            set: { (s, b) in (self.set(s.0, b.0), other.set(s.1, b.1)) })
    }
    
    public func first<C>() -> PLens<(S, C), (T, C), (A, C), (B, C)> {
        return PLens<(S, C), (T, C), (A, C), (B, C)>(
            get: { (s, c) in (self.get(s), c)},
            set: { (s, b) in (self.set(s.0, b.0), s.1) })
    }
    
    public func second<C>() -> PLens<(C, S), (C, T), (C, A), (C, B)> {
        return PLens<(C, S), (C, T), (C, A), (C, B)>(
            get: { (c, s) in (c, self.get(s)) },
            set: { (s, b) in (s.0, self.set(s.1, b.1)) })
    }
    
    public func compose<C, D>(_ other : PLens<A, B, C, D>) -> PLens<S, T, C, D> {
        return PLens<S, T, C, D>(
            get: self.get >>> other.get,
            set: { s, c in self.set(s, other.set(self.get(s), c)) })
    }
    
    public func compose<C, D>(_ other : PIso<A, B, C, D>) -> PLens<S, T, C, D> {
        return compose(other.asLens())
    }
    
    public func compose<C>(_ other : Getter<A, C>) -> Getter<S, C> {
        return self.asGetter().compose(other)
    }
    
    public func compose<C, D>(_ other : PPrism<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.asOptional().compose(other)
    }
    
    public func compose<C, D>(_ other : POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.asOptional().compose(other)
    }
    
    public func compose<C, D>(_ other : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.asSetter().compose(other)
    }
    
    public func compose<C>(_ other : Fold<A, C>) -> Fold<S, C> {
        return self.asFold().compose(other)
    }
    
    public func compose<C, D>(_ other : PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.asTraversal().compose(other)
    }
    
    public func asGetter() -> Getter<S, A> {
        return Getter(get: self.get)
    }
    
    public func asOptional() -> POptional<S, T, A, B> {
        return POptional(
            set: self.set,
            getOrModify: self.get >>> Either.right)
    }
    
    public func asSetter() -> PSetter<S, T, A, B> {
        return PSetter(modify: { f in { s in self.modify(s, f) } })
    }
    
    public func asFold() -> Fold<S, A> {
        return LensFold(lens: self)
    }
    
    public func asTraversal() -> PTraversal<S, T, A, B> {
        return LensTraversal(lens: self)
    }
    
    public func modify(_ s : S, _ f : @escaping (A) -> B) -> T {
        return set(s, f(get(s)))
    }
    
    public func lift(_ f : @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }
    
    public func find(_ s : S, _ predicate : (A) -> Bool) -> Maybe<A> {
        let a = get(s)
        return predicate(a) ? Maybe.some(a) : Maybe.none()
    }
    
    public func exists(_ s : S, _ predicate : (A) -> Bool) -> Bool {
        return predicate(get(s))
    }
}

fileprivate class LensFold<S, T, A, B> : Fold<S, A> {
    private let lens : PLens<S, T, A, B>
    
    init(lens : PLens<S, T, A, B>) {
        self.lens = lens
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: S, _ f: @escaping (A) -> R) -> R where Mono : Monoid, R == Mono.A {
        return f(lens.get(s))
    }
}

fileprivate class LensTraversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let lens : PLens<S, T, A, B>
    
    init(lens : PLens<S, T, A, B>) {
        self.lens = lens
    }
    
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> where Appl : Applicative, F == Appl.F {
        return applicative.map(f(self.lens.get(s)), { b in self.lens.set(s, b)})
    }
}
