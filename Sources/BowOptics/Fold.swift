import Foundation
import Bow

/// Witness for the `Fold<S, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForFold {}

/// Partial application of the Fold type constructor, omitting the last parameter.
public final class FoldPartial<S>: Kind<ForFold, S> {}

/// Higher Kinded Type alias to improve readability over `Kind2<ForFold, S, A>`.
public typealias FoldOf<S, A> = Kind<FoldPartial<S>, A>

/// A Fold is an optic that allows to focus into a structure and get multiple results.
///
/// Fold is a generalization of an instance of `Foldable` and it is implemented in terms of `foldMap`.
///
/// Type parameters:
///     - `S`: Source.
///     - `A`: Focus.
open class Fold<S, A>: FoldOf<S, A> {
    /// Creates a Fold that has no focus.
    public static var void: Fold<S, A> {
        return Optional<S, A>.void.asFold
    }

    /// Creates a Fold based on the instance of `Foldable` for `F`.
    ///
    /// - Returns: A Fold based on `Foldable` for `F`.
    public static func fromFoldable<F: Foldable>() -> Fold<Kind<F, A>, A> where S: Kind<F, A> {
        return FoldableFold()
    }
    
    /// Composes a `Fold` with a `Fold`.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the composition.
    ///   - rhs: Right hand side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Fold<S, A>, rhs: Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    /// Composes a `Fold` with an `Iso`.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the composition.
    ///   - rhs: Right hand side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Fold<S, A>, rhs: Iso<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    /// Composes a `Fold` with a `Getter`.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the composition.
    ///   - rhs: Right hand side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Fold<S, A>, rhs: Getter<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    /// Composes a `Fold` with a `Lens`.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the composition.
    ///   - rhs: Right hand side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Fold<S, A>, rhs: Lens<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    /// Composes a `Fold` with a `Prism`.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the composition.
    ///   - rhs: Right hand side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Fold<S, A>, rhs: Prism<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    /// Composes a `Fold` with an `Optional`.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the composition.
    ///   - rhs: Right hand side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Fold<S, A>, rhs: Optional<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    /// Composes a `Fold` with a `Traversal`.
    ///
    /// - Parameters:
    ///   - lhs: Left hand side of the composition.
    ///   - rhs: Right hand side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Fold<S, A>, rhs: Traversal<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    /// Map each foci to a type `R` and use a `Monoid` to fold the results.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Mapping function.
    /// - Returns: Summary value resulting from the fold.
    open func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        fatalError("foldMap must be overriden in subclasses")
    }

    /// Counts the number of foci in the source.
    ///
    /// - Parameter s: Source.
    /// - Returns: Number of foci.
    public func size(_ s: S) -> Int {
        return foldMap(s, constant(1))
    }

    /// Checks if all foci match a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: Boolean value indicating if all foci match the predicate.
    public func forAll(_ s: S, _ predicate: @escaping (A) -> Bool) -> Bool {
        return foldMap(s, predicate)
    }

    /// Checks if a source is empty.
    ///
    /// - Parameter s: Source.
    /// - Returns: True if the source has no foci; false otherwise.
    public func isEmpty(_ s: S) -> Bool {
        return !nonEmpty(s)
    }

    /// Checks if a source is non-empty.
    ///
    /// - Parameter s: Source.
    /// - Returns: False is the source has no foci; true otherwise.
    public func nonEmpty(_ s: S) -> Bool {
        return foldMap(s, constant(true))
    }

    /// Retrieves the first focus, if any.
    ///
    /// - Parameter s: Source.
    /// - Returns: An optional value with the first focus.
    public func headOption(_ s: S) -> Option<A> {
        return foldMap(s, FirstOption.init).const.value
    }

    /// Retrieves the last focus, if any.
    ///
    /// - Parameter s: Source.
    /// - Returns: An optional value with the last focus.
    public func lastOption(_ s: S) -> Option<A> {
        return foldMap(s, LastOption.init).const.value
    }

    /// Gets all foci.
    ///
    /// - Parameter s: Source.
    /// - Returns: An `ArrayK` with all foci.
    public func getAll(_ s: S) -> ArrayK<A> {
        return foldMap(s, { x in ArrayK(x) })
    }

    /// Joins to Fold with the same focus.
    ///
    /// - Parameter other: Fold to join with.
    /// - Returns: A Fold that operates on either of the two original sources, with the same target.
    public func choice<C>(_ other: Fold<C, A>) -> Fold<Either<S, C>, A> {
        return ChoiceFold(first: self, second: other)
    }

    /// Creates the sum of this `Fold` with another type, placing this as the left side.
    ///
    /// - Returns: A `Fold` that operates on `Either`s where the right side remains unchanged.
    public func left<C>() -> Fold<Either<S, C>, Either<A, C>> {
        return LeftFold(fold: self)
    }

    /// Creates the sum of this `Fold` with another type, placing this as the right side.
    ///
    /// - Returns: A `Fold` that operates on `Either`s where the left side remains unchanged.
    public func right<C>() -> Fold<Either<C, S>, Either<C, A>> {
        return RightFold(fold: self)
    }

    /// Composes this `Fold` with a `Fold`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Fold<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other)
    }

    /// Composes this `Fold` with an `Iso`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Iso<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold)
    }

    /// Composes this `Fold` with a `Getter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Getter<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold)
    }

    /// Composes this `Fold` with a `Lens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Lens<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold)
    }

    /// Composes this `Fold` with a `Prism`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Prism<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold)
    }

    /// Composes this `Fold` with an `Optional`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Optional<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold)
    }

    /// Composes this `Fold` with a `Traversal`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Traversal<A, C>) -> Fold<S, C> {
        return ComposeFold(first: self, second: other.asFold)
    }

    /// Finds the first focus that matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: An optional value containing the focus, if any.
    public func find(_ s: S, _ predicate: @escaping (A) -> Bool) -> Option<A> {
        return foldMap(s, { a in predicate(a) ? FirstOption(a): FirstOption(Option.none()) }).const.value
    }

    /// Checks if any focus in the provided source match a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: True if any focus matches the predicate; false otherwise.
    public func exists(_ s: S, _ predicate: @escaping (A) -> Bool) -> Bool {
        return find(s, predicate).fold(constant(false), constant(true))
    }
}

public extension Fold where S == A {
    /// Provides an identity Fold.
    static var identity: Fold<S, S> {
        return Iso<S, S>.identity.asFold
    }
    
    /// Provides a Fold that takes either an `S` or an `S` and strips the choice of `S`.
    static var codiagonal: Fold<Either<S, S>, S> {
        return CodiagonalFold<S>()
    }
    
    /// Provides a Fold based on a predicate on the source.
    ///
    /// - Parameter predicate: Testing predicate.
    /// - Returns: A Fold based on the provided predicate.
    static func select(_ predicate: @escaping (S) -> Bool) -> Fold<S, S> {
        return SelectFold<S>(predicate: predicate)
    }
}

public extension Fold where A: Monoid {
    /// Folds all foci into a summary value using its instance of `Monoid`.
    ///
    /// - Parameter s: Source.
    /// - Returns: Summary value.
    func fold(_ s: S) -> A {
        return foldMap(s, id)
    }

    /// Folds all foci into a summary value using its instance of `Monoid`.
    ///
    /// - Parameter s: Source.
    /// - Returns: Summary value.
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
