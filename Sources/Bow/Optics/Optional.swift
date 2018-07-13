import Foundation

public class ForPOptional {}
public typealias POptionalOf<S, T, A, B> = Kind4<ForPOptional, S, T, A, B>
public typealias POptionalPartial<S, T, A> = Kind3<ForPOptional, S, T, A>

public typealias ForOptional = ForPOptional
public typealias Optional<S, A> = POptional<S, S, A, A>
public typealias OptionalPartial<S> = Kind<ForOptional, S>

public class POptional<S, T, A, B> : POptionalOf<S, T, A, B> {
    private let setFunc : (S, B) -> T
    private let getOrModifyFunc : (S) -> Either<T, A>
    
    public static func +<C, D>(lhs : POptional<S, T, A, B>, rhs : POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : POptional<S, T, A, B>, rhs : PPrism<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : POptional<S, T, A, B>, rhs : PLens<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : POptional<S, T, A, B>, rhs : PIso<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : POptional<S, T, A, B>, rhs : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : POptional<S, T, A, B>, rhs : Getter<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C>(lhs : POptional<S, T, A, B>, rhs : Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    public static func +<C, D>(lhs : POptional<S, T, A, B>, rhs : PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    public static func identity() -> Optional<S, S> {
        return Iso<S, S>.identity().asOptional()
    }
    
    public static func codiagonal() -> Optional<Either<S, S>, S> {
        return Optional<Either<S, S>, S>(
            set: { ess, s in ess.bimap(constant(s), constant(s)) },
            getOrModify: { ess in ess.fold(Either.right, Either.right) })
    }
    
    public static func void() -> Optional<S, A> {
        return Optional(set: { s, _ in s }, getOrModify: { s in Either<S, A>.left(s) })
    }
    
    public init(set : @escaping (S, B) -> T, getOrModify : @escaping (S) -> Either<T, A>) {
        self.setFunc = set
        self.getOrModifyFunc = getOrModify
    }
    
    public func set(_ s : S, _ b : B) -> T {
        return setFunc(s, b)
    }
    
    public func getOrModify(_ s : S) -> Either<T, A> {
        return getOrModifyFunc(s)
    }
    
    public func modifyF<Appl, F>(_ applicative : Appl, _ s : S, _ f : @escaping (A) -> Kind<F, B>) -> Kind<F, T> where Appl : Applicative, Appl.F == F {
        return getOrModify(s).fold(applicative.pure, { a in applicative.map(f(a)){ b in self.set(s, b) } })
    }
    
    public func liftF<Appl, F>(_ applicative : Appl, _ f : @escaping (A) -> Kind<F, B>) -> (S) -> Kind<F, T> where Appl : Applicative, Appl.F == F {
        return { s in self.modifyF(applicative, s, f) }
    }
    
    public func getMaybe(_ s : S) -> Maybe<A> {
        return getOrModify(s).toMaybe()
    }
    
    public func setMaybe(_ s : S, _ b : B) -> Maybe<T> {
        return modifyMaybe(s, constant(b))
    }
    
    public func isEmpty(_ s : S) -> Bool {
        return !nonEmpty(s)
    }
    
    public func nonEmpty(_ s : S) -> Bool {
        return getMaybe(s).fold(constant(false), constant(true))
    }
    
    public func choice<S1, T1>(_ other : POptional<S1, T1, A, B>) -> POptional<Either<S, S1>, Either<T, T1>, A, B> {
        return POptional<Either<S, S1>, Either<T, T1>, A, B>(set: { either, b in
            either.bimap({ s in self.set(s, b) }, { s in other.set(s, b) })
        }, getOrModify: { either in
            either.fold({ s in self.getOrModify(s).bimap(Either.left, id) },
                        { s in other.getOrModify(s).bimap(Either.right, id) })
        })
    }
    
    public func first<C>() -> POptional<(S, C), (T, C), (A, C), (B, C)> {
        return POptional<(S, C), (T, C), (A, C), (B, C)>(
            set: { sc, bc in self.setMaybe(sc.0, bc.0).fold({ (self.set(sc.0, bc.0), bc.1) }, { t in (t, sc.1) }) },
            getOrModify: { s, c in self.getOrModify(s).bimap({ t in (t, c) }, { a in (a, c) }) })
    }
    
    public func second<C>() -> POptional<(C, S), (C, T), (C, A), (C, B)> {
        return POptional<(C, S), (C, T), (C, A), (C, B)>(
            set: { cs, cb in self.setMaybe(cs.1, cb.1).fold({ (cs.0, self.set(cs.1, cb.1)) }, { t in (cb.0, t)}) },
            getOrModify: { c, s in self.getOrModify(s).bimap({ t in (c, t) }, { a in (c, a) })
        })
    }
    
    public func modify(_ s : S, _ f : @escaping (A) -> B) -> T {
        return getOrModify(s).fold(id, { a in self.set(s, f(a)) })
    }
    
    public func lift(_ f : @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }
    
    public func modifyMaybe(_ s : S, _ f : @escaping (A) -> B) -> Maybe<T> {
        return getMaybe(s).map { a in self.set(s, f(a)) }
    }
    
    public func find(_ s : S, _ predicate : @escaping (A) -> Bool) -> Maybe<A> {
        return getMaybe(s).flatMap { a in predicate(a) ? Maybe.some(a) : Maybe.none() }
    }
    
    public func exists(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return getMaybe(s).fold(constant(false), predicate)
    }
    
    public func all(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return getMaybe(s).fold(constant(true), predicate)
    }
    
    public func compose<C, D>(_ other : POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return POptional<S, T, C, D>(
            set: { s, d in
                self.modify(s){ a in other.set(a, d) }
        },
            getOrModify: { s in
                self.getOrModify(s).flatMap { a in other.getOrModify(a).bimap({ t in self.set(s, t) }, id)}
        })
    }
    
    public func compose<C, D>(_ other : PPrism<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.compose(other.asOptional())
    }
    
    public func compose<C, D>(_ other : PLens<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.compose(other.asOptional())
    }
    
    public func compose<C, D>(_ other : PIso<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.compose(other.asOptional())
    }
    
    public func compose<C, D>(_ other : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.asSetter().compose(other)
    }
    
    public func compose<C>(_ other : Getter<A, C>) -> Fold<S, C> {
        return self.asFold().compose(other)
    }
    
    public func compose<C>(_ other : Fold<A, C>) -> Fold<S, C> {
        return self.asFold().compose(other)
    }
    
    public func compose<C, D>(_ other : PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.asTraversal().compose(other)
    }
    
    public func asSetter() -> PSetter<S, T, A, B> {
        return PSetter(modify: { f in { s in self.modify(s, f) } })
    }
    
    public func asFold() -> Fold<S, A> {
        return OptionalFold(optional: self)
    }
    
    public func asTraversal() -> PTraversal<S, T, A, B> {
        return OptionalTraversal(optional: self)
    }
}

fileprivate class OptionalFold<S, T, A, B> : Fold<S, A> {
    private let optional : POptional<S, T, A, B>
    
    init(optional : POptional<S, T, A, B>) {
        self.optional = optional
    }
    
    override func foldMap<Mono, R>(_ monoid: Mono, _ s: S, _ f: @escaping (A) -> R) -> R where Mono : Monoid, R == Mono.A {
        return optional.getMaybe(s).map(f).getOrElse(monoid.empty)
    }
}

fileprivate class OptionalTraversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let optional : POptional<S, T, A, B>
    
    init(optional : POptional<S, T, A, B>) {
        self.optional = optional
    }
    
    override func modifyF<Appl, F>(_ applicative: Appl, _ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> where Appl : Applicative, F == Appl.F {
        return self.optional.modifyF(applicative, s, f)
    }
}
