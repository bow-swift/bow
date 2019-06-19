import Foundation
import Bow

public final class ForPPrism {}
public final class PPrismPartial<S, T, A>: Kind3<ForPPrism, S, T, A> {}
public typealias PPrismOf<S, T, A, B> = Kind<PPrismPartial<S, T, A>, B>

public typealias ForPrism = ForPPrism
public typealias Prism<S, A> = PPrism<S, S, A, A>
public typealias PrismPartial<S> = Kind<ForPrism, S>

public class PPrism<S, T, A, B> : PPrismOf<S, T, A, B> {
    private let getOrModifyFunc : (S) -> Either<T, A>
    private let reverseGetFunc : (B) -> T

    public static func +<C, D>(lhs : PPrism<S, T, A, B>, rhs : PPrism<A, B, C, D>) -> PPrism<S, T, C, D> {
        return lhs.compose(rhs)
    }

    public static func +<C, D>(lhs : PPrism<S, T, A, B>, rhs : PIso<A, B, C, D>) -> PPrism<S, T, C, D> {
        return lhs.compose(rhs)
    }

    public static func +<C, D>(lhs : PPrism<S, T, A, B>, rhs : PLens<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }

    public static func +<C, D>(lhs : PPrism<S, T, A, B>, rhs : POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }

    public static func +<C, D>(lhs : PPrism<S, T, A, B>, rhs : PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }

    public static func +<C>(lhs : PPrism<S, T, A, B>, rhs : Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    public static func +<C, D>(lhs : PPrism<S, T, A, B>, rhs : PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }

    public static func identity() -> Prism<S, S> {
        return Iso<S, S>.identity().asPrism()
    }

    public init(getOrModify : @escaping (S) -> Either<T, A>, reverseGet : @escaping (B) -> T) {
        self.getOrModifyFunc = getOrModify
        self.reverseGetFunc = reverseGet
    }

    public func getOrModify(_ s : S) -> Either<T, A> {
        return getOrModifyFunc(s)
    }

    public func reverseGet(_ b : B) -> T {
        return reverseGetFunc(b)
    }

    public func modifyF<F: Applicative>(_ s : S, _ f : @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return getOrModify(s).fold(F.pure,
                                   { a in F.map(f(a), self.reverseGet) })
    }

    public func liftF<F: Applicative>(_ f : @escaping (A) -> Kind<F, B>) -> (S) -> Kind<F, T> {
        return { s in self.modifyF(s, f) }
    }

    public func getOption(_ s : S) -> Option<A> {
        return getOrModify(s).toOption()
    }

    public func set(_ s : S, _ b : B) -> T {
        return modify(s, constant(b))
    }

    public func setOption(_ s : S, _ b : B) -> Option<T> {
        return modifyOption(s, constant(b))
    }

    public func nonEmpty(_ s : S) -> Bool {
        return getOption(s).fold(constant(false), constant(true))
    }

    public func isEmpty(_ s : S) -> Bool {
        return !nonEmpty(s)
    }

    public func first<C>() -> PPrism<(S, C), (T, C), (A, C), (B, C)> {
        return PPrism<(S, C), (T, C), (A, C), (B, C)>(
            getOrModify: { s, c in
                self.getOrModify(s).bimap({ t in (t, c) }, { a in (a, c) })
        },
            reverseGet: { b, c in
                (self.reverseGet(b), c)
        })
    }

    public func second<C>() -> PPrism<(C, S), (C, T), (C, A), (C, B)> {
        return PPrism<(C, S), (C, T), (C, A), (C, B)>(
            getOrModify: { c, s in
                self.getOrModify(s).bimap({ t in (c, t) }, { a in (c, a) })
        },
            reverseGet: { c, b in
                (c, self.reverseGet(b))
        })
    }

    public func modify(_ s : S, _ f : @escaping (A) -> B) -> T {
        return getOrModify(s).fold(id, { a in self.reverseGet(f(a)) })
    }

    public func lift(_ f : @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }

    public func modifyOption(_ s : S, _ f : @escaping (A) -> B) -> Option<T> {
        return Option.fix(getOption(s).map { a in self.reverseGet(f(a)) })
    }

    public func liftOption(_ f : @escaping (A) -> B) -> (S) -> Option<T> {
        return { s in self.modifyOption(s, f) }
    }

    public func find(_ s : S, _ predicate : @escaping (A) -> Bool) -> Option<A> {
        return Option.fix(getOption(s).flatMap { a in predicate(a) ? Option.some(a) : Option.none() })
    }

    public func exists(_ s : S, _ predicate : @escaping (A) -> Bool) -> Bool {
        return getOption(s).fold(constant(false), predicate)
    }

    public func all(_ s : S, _ predicate : @escaping(A) -> Bool) -> Bool {
        return getOption(s).fold(constant(true), predicate)
    }

    public func left<C>() -> PPrism<Either<S, C>, Either<T, C>, Either<A, C>, Either<B, C>> {
        return PPrism<Either<S, C>, Either<T, C>, Either<A, C>, Either<B, C>>(
            getOrModify: { esc in
                esc.fold({ s in self.getOrModify(s).bimap(Either.left, Either.left) },
                         { c in Either.right(Either.right(c)) })
        },
            reverseGet: { ebc in
                ebc.fold({ b in Either.left(self.reverseGet(b)) }, { c in Either.right(c) })
        })
    }

    public func right<C>() -> PPrism<Either<C, S>, Either<C, T>, Either<C, A>, Either<C, B>> {
        return PPrism<Either<C, S>, Either<C, T>, Either<C, A>, Either<C, B>>(
            getOrModify: { ecs in
                ecs.fold({ c in Either.right(Either.left(c)) },
                         { s in self.getOrModify(s).bimap(Either.right, Either.right) })
        },
            reverseGet: { ecb in
                Either.fix(ecb.map(self.reverseGet))
        })
    }

    public func compose<C, D>(_ other : PPrism<A, B, C, D>) -> PPrism<S, T, C, D> {
        return PPrism<S, T, C, D>(
            getOrModify: { s in
                Either.fix(self.getOrModify(s).flatMap{ a in other.getOrModify(a).bimap({ b in self.set(s, b) }, id)})
        },
            reverseGet: self.reverseGet <<< other.reverseGet)
    }

    public func compose<C, D>(_ other : PIso<A, B, C, D>) -> PPrism<S, T, C, D> {
        return self.compose(other.asPrism())
    }

    public func compose<C, D>(_ other : PLens<A, B, C, D>) -> POptional<S, T, C, D> {
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

    public func asOptional() -> POptional<S, T, A, B> {
        return POptional(set: self.set, getOrModify: self.getOrModify)
    }

    public func asSetter() -> PSetter<S, T, A, B> {
        return PSetter(modify: { f in {s in self.modify(s, f) } })
    }

    public func asFold() -> Fold<S, A> {
        return PrismFold(prism: self)
    }

    public func asTraversal() -> PTraversal<S, T, A, B> {
        return PrismTraversal(prism: self)
    }
}

public extension Prism where A: Equatable {
    static func only(_ a: A) -> Prism<A, ()> {
        return Prism<A, ()>(getOrModify: { x in a == x ? Either.left(a) : Either.right(unit)},
                            reverseGet: { _ in a })
    }
}

private class PrismFold<S, T, A, B> : Fold<S, A> {
    private let prism : PPrism<S, T, A, B>

    init(prism : PPrism<S, T, A, B>) {
        self.prism = prism
    }

    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        return Option.fix(prism.getOption(s).map(f)).getOrElse(R.empty())
    }
}

private class PrismTraversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let prism : PPrism<S, T, A, B>

    init(prism : PPrism<S, T, A, B>) {
        self.prism = prism
    }

    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return prism.getOrModify(s)
            .fold(F.pure,
                  { a in F.map(f(a), prism.reverseGet) })
    }
}

extension Prism {
    internal var fix: Prism<S, A> {
        return self as! Prism<S, A>
    }
}
