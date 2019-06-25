import Foundation
import Bow

public final class ForPLens {}
public final class PLensPartial<S, T, A>: Kind3<ForPLens, S, T, A> {}
public typealias PLensOf<S, T, A, B> = Kind<PLensPartial<S, T, A>, B>

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
    
    public func modifyF<F: Functor>(_ s : S, _ f : @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get(s)), { b in self.set(s, b) })
    }
    
    public func liftF<F: Functor>(_ f : @escaping (A) -> Kind<F, B>) -> (S) -> Kind<F, T> {
        return { s in self.modifyF(s, f) }
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
        return compose(other.asLens)
    }
    
    public func compose<C>(_ other : Getter<A, C>) -> Getter<S, C> {
        return self.asGetter.compose(other)
    }
    
    public func compose<C, D>(_ other : PPrism<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.asOptional.compose(other)
    }
    
    public func compose<C, D>(_ other : POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.asOptional.compose(other)
    }
    
    public func compose<C, D>(_ other : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.asSetter.compose(other)
    }
    
    public func compose<C>(_ other : Fold<A, C>) -> Fold<S, C> {
        return self.asFold.compose(other)
    }
    
    public func compose<C, D>(_ other : PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.asTraversal.compose(other)
    }
    
    public var asGetter: Getter<S, A> {
        return Getter(get: self.get)
    }
    
    public var asOptional: POptional<S, T, A, B> {
        return POptional(
            set: self.set,
            getOrModify: self.get >>> Either.right)
    }
    
    public var asSetter: PSetter<S, T, A, B> {
        return PSetter(modify: { f in { s in self.modify(s, f) } })
    }
    
    public var asFold: Fold<S, A> {
        return LensFold(lens: self)
    }
    
    public var asTraversal: PTraversal<S, T, A, B> {
        return LensTraversal(lens: self)
    }
    
    public func modify(_ s : S, _ f : @escaping (A) -> B) -> T {
        return set(s, f(get(s)))
    }
    
    public func lift(_ f : @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }
    
    public func find(_ s : S, _ predicate : (A) -> Bool) -> Option<A> {
        let a = get(s)
        return predicate(a) ? Option.some(a) : Option.none()
    }
    
    public func exists(_ s : S, _ predicate : (A) -> Bool) -> Bool {
        return predicate(get(s))
    }
    
    public func ask() -> Reader<S, A> {
        return Reader(get >>> Id.pure)
    }
    
    public func toReader() -> Reader<S, A> {
        return ask()
    }
    
    public func asks<C>(_ f: @escaping (A) -> C) -> Reader<S, C> {
        return ask().map(f)^
    }
    
    public func extract() -> State<S, A> {
        return State { s in (s, self.get(s)) }
    }
    
    public func toState() -> State<S, A> {
        return extract()
    }
    
    public func extractMap<C>(_ f: @escaping (A) -> C) -> State<S, C> {
        return extract().map(f)^
    }
}

public extension Lens where S == T, A == B {
    func update(_ f: @escaping (A) -> A) -> State<S, A> {
        return State { s in
            let b = f(self.get(s))
            return (self.set(s, b), b)
        }
    }
    
    func updateOld(_ f: @escaping (A) -> A) -> State<S, A> {
        return State { s in (self.modify(s, f), self.get(s)) }
    }
    
    func update_(_ f: @escaping (A) -> A) -> State<S, ()> {
        return State { s in (self.modify(s, f), ()) }
    }
    
    func assign(_ a: A) -> State<S, A> {
        return update(constant(a))
    }
    
    func assignOld(_ a: A) -> State<S, A> {
        return updateOld(constant(a))
    }
    
    func assign_(_ a: A) -> State<S, ()> {
        return update_(constant(a))
    }
}

public extension Lens where S == A {
    static var identity: Lens<S, S> {
        return Iso<S, S>.identity.asLens
    }
    
    static var codiagonal: Lens<Either<S, S>, S> {
        return Lens<Either<S, S>, S>(
            get: { ess in ess.fold(id, id) },
            set: { ess, s in ess.bimap(constant(s), constant(s)) })
    }
}

private class LensFold<S, T, A, B> : Fold<S, A> {
    private let lens : PLens<S, T, A, B>
    
    init(lens : PLens<S, T, A, B>) {
        self.lens = lens
    }
    
    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        return f(lens.get(s))
    }
}

private class LensTraversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let lens : PLens<S, T, A, B>
    
    init(lens : PLens<S, T, A, B>) {
        self.lens = lens
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.lens.get(s)), { b in self.lens.set(s, b)})
    }
}

extension Lens {
    internal var fix: Lens<S, A> {
        return self as! Lens<S, A>
    }
}
