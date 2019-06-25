import Foundation
import Bow

public final class ForFold {}
public final class FoldPartial<S>: Kind<ForFold, S> {}
public typealias FoldOf<S, A> = Kind<FoldPartial<S>, A>

open class Fold<S, A>: FoldOf<S, A> {
    public static func void() -> Fold<S, A> {
        return Optional<S, A>.void().asFold()
    }

    public static func fromFoldable<F: Foldable>() -> Fold<Kind<F, A>, A> where S: Kind<F, A> {
        return FoldableFold()
    }
    
    public static func +<C>(lhs: Fold<S, A>, rhs: Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    public static func +<C>(lhs: Fold<S, A>, rhs: Iso<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    public static func +<C>(lhs: Fold<S, A>, rhs: Getter<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    public static func +<C>(lhs: Fold<S, A>, rhs: Lens<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    public static func +<C>(lhs: Fold<S, A>, rhs: Prism<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    public static func +<C>(lhs: Fold<S, A>, rhs: Optional<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    public static func +<C>(lhs: Fold<S, A>, rhs: Traversal<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    open func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        fatalError("foldMap must be overriden in subclasses")
    }

    public func size(_ s: S) -> Int {
        return foldMap(s, constant(1))
    }

    public func forAll(_ s: S, _ predicate: @escaping (A) -> Bool) -> Bool {
        return foldMap(s, predicate)
    }

    public func isEmpty(_ s: S) -> Bool {
        return foldMap(s, constant(false))
    }

    public func nonEmpty(_ s: S) -> Bool {
        return !isEmpty(s)
    }

    public func headOption(_ s: S) -> Option<A> {
        return foldMap(s, FirstOption.init).const.value
    }

    public func lastOption(_ s: S) -> Option<A> {
        return foldMap(s, LastOption.init).const.value
    }

    public func getAll(_ s: S) -> ArrayK<A> {
        return foldMap(s, { x in ArrayK.fix(ArrayK<A>.pure(x)) })
    }

    public func choice<C>(_ other: Fold<C, A>) -> Fold<Either<S, C>, A> {
        return ChoiceFold(first: self, second: other)
    }

    public func left<C>() -> Fold<Either<S, C>, Either<A, C>> {
        return LeftFold(fold: self)
    }

    public func right<C>() -> Fold<Either<C, S>, Either<C, A>> {
        return RightFold(fold: self)
    }

    public func compose<C>(_ other: Fold<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other)
    }

    public func compose<C>(_ other: Iso<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold)
    }

    public func compose<C>(_ other: Getter<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }

    public func compose<C>(_ other: Lens<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }

    public func compose<C>(_ other: Prism<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }

    public func compose<C>(_ other: Optional<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }

    public func compose<C>(_ other: Traversal<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold())
    }

    public func find(_ s: S, _ predicate: @escaping (A) -> Bool) -> Option<A> {
        return foldMap(s, { a in predicate(a) ? FirstOption(a): FirstOption(Option.none()) }).const.value
    }

    public func exists(_ s: S, _ predicate: @escaping (A) -> Bool) -> Bool {
        return find(s, predicate).fold(constant(false), constant(true))
    }
}

public extension Fold where S == A {
    static func identity() -> Fold<S, S> {
        return Iso<S, S>.identity.asFold
    }
    
    static func codiagonal() -> Fold<Either<S, S>, S> {
        return CodiagonalFold<S>()
    }
    
    static func select(_ predicate: @escaping (S) -> Bool) -> Fold<S, S> {
        return SelectFold<S>(predicate: predicate)
    }
}

public extension Fold where A: Monoid {
    func fold(_ s: S) -> A {
        return foldMap(s, id)
    }

    func combineAll(_ s: S) -> A {
        return foldMap(s, id)
    }
}

private class CodiagonalFold<S>: Fold<Either<S, S>, S> {
    override func foldMap<R: Monoid>(_ s: Either<S, S>, _ f: @escaping (S) -> R) -> R {
        return s.fold(f, f)
    }
}

private class SelectFold<S>: Fold<S, S> {
    private let predicate: (S) -> Bool

    init(predicate: @escaping (S) -> Bool) {
        self.predicate = predicate
    }

    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (S) -> R) -> R {
        return predicate(s) ? f(s): R.empty()
    }
}

private class FoldableFold<F: Foldable, S>: Fold<Kind<F, S>, S> {
    override func foldMap<R: Monoid>(_ s: Kind<F, S>, _ f: @escaping (S) -> R) -> R {
        return F.foldMap(s, f)
    }
}

private class ChoiceFold<S, C, A>: Fold<Either<S, C>, A> {
    private let first: Fold<S, A>
    private let second: Fold<C, A>

    init(first: Fold<S, A>, second: Fold<C, A>) {
        self.first = first
        self.second = second
    }

    override func foldMap<R: Monoid>(_ esc: Either<S, C>, _ f: @escaping (A) -> R) -> R {
        return esc.fold({ s in first.foldMap(s, f)},
                        { c in second.foldMap(c, f)})
    }
}

private class LeftFold<S, C, A>: Fold<Either<S, C>, Either<A, C>> {
    private let fold: Fold<S, A>

    init(fold: Fold<S, A>) {
        self.fold = fold
    }

    override func foldMap<R: Monoid>(_ s: Either<S, C>, _ f: @escaping (Either<A, C>) -> R) -> R  {
        return s.fold({ a1 in fold.foldMap(a1, { b in f(Either.left(b)) }) },
                      { c in f(Either.right(c)) })
    }
}

private class RightFold<S, C, A>: Fold<Either<C, S>, Either<C, A>> {
    private let fold: Fold<S, A>

    init(fold: Fold<S, A>) {
        self.fold = fold
    }

    override func foldMap<R: Monoid>(_ s: Either<C, S>, _ f: @escaping (Either<C, A>) -> R) -> R {
        return s.fold({ c in f(Either.left(c)) },
                      { a1 in fold.foldMap(a1, { b in f(Either.right(b)) }) })
    }
}

private class ComposeFold<S, C, A>: Fold<S, C> {
    private let first: Fold<S, A>
    private let second: Fold<A, C>

    init(first: Fold<S, A>, second: Fold<A, C>) {
        self.first = first
        self.second = second
    }

    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (C) -> R) -> R {
        return self.first.foldMap(s, { c in self.second.foldMap(c, f) })
    }
}
