import Foundation
import Bow

/// Witness for the `PPrism<S, T, A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForPPrism {}

/// Partial application of the PPrism type constructor, omitting the last parameter.
public final class PPrismPartial<S, T, A>: Kind3<ForPPrism, S, T, A> {}

/// Higher Kinded Type alias to improve readability over `Kind4<ForPPrism, S, T, A, B>`.
public typealias PPrismOf<S, T, A, B> = Kind<PPrismPartial<S, T, A>, B>

/// Prism is a type alias for PPrism which fixes the type arguments and restricts the PPrism to monomorphic updates.
public typealias Prism<S, A> = PPrism<S, S, A, A>

/// Witness for the `Prism<S, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForPrism = ForPPrism

/// Partial application of the `Prism` type constructor, omitting the last parameter.
public typealias PrismPartial<S> = Kind<ForPrism, S>

/// A Prism is a loss less invertible optic that can look into a structure and optionally find its focus. It is mostly used for finding a focus that is only present under certain conditions, like in a sum type.
///
/// A (polymorphic) PPrism is useful when setting or modifying a value for a polymorphic sum type.
///
/// A PPrism gathres the two concepts of pattern matching and constructor and thus can be seen as a pair of functions:
///     - `getOrModify` meaning it returns the focus of a PPRism or the original value.
///     - `reverseGet` meaining we can construct the source type of a PPrism from a focus.
///
/// Type parameters:
///     - `S`: Source.
///     - `T`: Modified source.
///     - `A`: Focus.
///     - `B`: Modified focus.
public class PPrism<S, T, A, B>: PPrismOf<S, T, A, B> {
    private let getOrModifyFunc: (S) -> Either<T, A>
    private let reverseGetFunc: (B) -> T

    /// Composes a `PPrism` with a `PPrism`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PPrism` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PPrism<S, T, A, B>, rhs: PPrism<A, B, C, D>) -> PPrism<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PPrism` with a `PIso`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PPrism` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PPrism<S, T, A, B>, rhs: PIso<A, B, C, D>) -> PPrism<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PPrism` with a `PLens`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `POptional` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PPrism<S, T, A, B>, rhs: PLens<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PPrism` with a `POptional`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `POptional` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PPrism<S, T, A, B>, rhs: POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PPrism` with a `PSetter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PPrism<S, T, A, B>, rhs: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PPrism` with a `Fold`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: PPrism<S, T, A, B>, rhs: Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    /// Composes a `PPrism` with a `PTraversal`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PPrism<S, T, A, B>, rhs: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Initializes a Prism.
    ///
    /// - Parameters:
    ///   - getOrModify: Gets the focus of the prism, if present.
    ///   - reverseGet: Builds the source of the prism from its focus.
    public init(getOrModify: @escaping (S) -> Either<T, A>, reverseGet: @escaping (B) -> T) {
        self.getOrModifyFunc = getOrModify
        self.reverseGetFunc = reverseGet
    }

    /// Retrieves the focus or modifies the source.
    ///
    /// - Parameter s: Source.
    /// - Returns: Either the modified source or the focus of the prism.
    public func getOrModify(_ s: S) -> Either<T, A> {
        return getOrModifyFunc(s)
    }

    /// Obtains a modified source.
    ///
    /// - Parameter b: Modified focus.
    /// - Returns: Modified source.
    public func reverseGet(_ b: B) -> T {
        return reverseGetFunc(b)
    }

    /// Modifies the focus of a PPrism with an `Applicative` function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: Modified source in the context of the `Applicative`.
    public func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return getOrModify(s).fold(F.pure,
                                   { a in F.map(f(a), self.reverseGet) })
    }

    /// Lifts an `Applicative` function operating on focus to one operating on source.
    ///
    /// - Parameter f: Modifying function.
    /// - Returns: Lifted function operating on the source.
    public func liftF<F: Applicative>(_ f: @escaping (A) -> Kind<F, B>) -> (S) -> Kind<F, T> {
        return { s in self.modifyF(s, f) }
    }

    /// Retrieves the focus.
    ///
    /// - Parameter s: Source.
    /// - Returns: An optional value that is present if the focus exists.
    public func getOption(_ s: S) -> Option<A> {
        return getOrModify(s).toOption()
    }

    /// Obtains a modified source.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - b: Modified focus.
    /// - Returns: Modified source.
    public func set(_ s: S, _ b: B) -> T {
        return modify(s, constant(b))
    }

    /// Sets a modified focus.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - b: Modified focus.
    /// - Returns: Optional modified source.
    public func setOption(_ s: S, _ b: B) -> Option<T> {
        return modifyOption(s, constant(b))
    }

    /// Checks if the provided source is non-empty.
    ///
    /// - Parameter s: Source.
    /// - Returns: Boolean value indicating if the provided source is non-empty.
    public func nonEmpty(_ s: S) -> Bool {
        return getOption(s).fold(constant(false), constant(true))
    }

    /// Checks if the provided source is empty.
    ///
    /// - Parameter s: Source.
    /// - Returns: Boolean value indicating if the provided source is empty.
    public func isEmpty(_ s: S) -> Bool {
        return !nonEmpty(s)
    }

    /// Pairs this `PPrism` with another type, placing this as the first element.
    ///
    /// - Returns: A `PPrism` that operates on tuples where the second argument remains unchanged.
    public func first<C>() -> PPrism<(S, C), (T, C), (A, C), (B, C)> {
        return PPrism<(S, C), (T, C), (A, C), (B, C)>(
            getOrModify: { s, c in
                self.getOrModify(s).bimap({ t in (t, c) }, { a in (a, c) })
        },
            reverseGet: { b, c in
                (self.reverseGet(b), c)
        })
    }

    /// Pairs this `PPrism` with another type, placing this as the second element.
    ///
    /// - Returns: A `PPrism` that operates on tuples where the first argument remains unchanged.
    public func second<C>() -> PPrism<(C, S), (C, T), (C, A), (C, B)> {
        return PPrism<(C, S), (C, T), (C, A), (C, B)>(
            getOrModify: { c, s in
                self.getOrModify(s).bimap({ t in (c, t) }, { a in (c, a) })
        },
            reverseGet: { c, b in
                (c, self.reverseGet(b))
        })
    }

    /// Modifies the source with the provided function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: Modified source.
    public func modify(_ s: S, _ f: @escaping (A) -> B) -> T {
        return getOrModify(s).fold(id, { a in self.reverseGet(f(a)) })
    }

    /// Lifts a function modifying the focus to one modifying the source.
    ///
    /// - Parameter f: Modifying function.
    /// - Returns: Function that modifies the source.
    public func lift(_ f: @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }

    /// Optionally modifies the source with a function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: Optional modified source.
    public func modifyOption(_ s: S, _ f: @escaping (A) -> B) -> Option<T> {
        return Option.fix(getOption(s).map { a in self.reverseGet(f(a)) })
    }

    /// Lifts a function modifying the focus to a function that optionally modifies the source.
    ///
    /// - Parameter f: Modifying function.
    /// - Returns: Function that optionally modifies the source.
    public func liftOption(_ f: @escaping (A) -> B) -> (S) -> Option<T> {
        return { s in self.modifyOption(s, f) }
    }

    /// Retrieves the focus if it matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: An optional focus that is present if it matches the predicate.
    public func find(_ s: S, _ predicate: @escaping (A) -> Bool) -> Option<A> {
        return Option.fix(getOption(s).flatMap { a in predicate(a) ? Option.some(a) : Option.none() })
    }

    /// Checks if the focus matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: Boolean value indicating if the focus matches the predicate.
    public func exists(_ s: S, _ predicate: @escaping (A) -> Bool) -> Bool {
        return getOption(s).fold(constant(false), predicate)
    }

    /// Checks if the focus matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: Boolean value indicating if the focus matches the predicate.
    public func all(_ s: S, _ predicate: @escaping(A) -> Bool) -> Bool {
        return getOption(s).fold(constant(true), predicate)
    }

    /// Creates the sum of this `PPrism` with another type, placing this as the left side.
    ///
    /// - Returns: A `PPrism` that operates on `Either`s where the right side remains unchanged.
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

    /// Creates the sum of this `PPrism` with another type, placing this as the right side.
    ///
    /// - Returns: A `PPrism` that operates on `Either`s where the left side remains unchanged.
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

    /// Composes this value with a `PPrism`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PPrism` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PPrism<A, B, C, D>) -> PPrism<S, T, C, D> {
        return PPrism<S, T, C, D>(
            getOrModify: { s in
                Either.fix(self.getOrModify(s).flatMap{ a in other.getOrModify(a).bimap({ b in self.set(s, b) }, id)})
        },
            reverseGet: self.reverseGet <<< other.reverseGet)
    }

    /// Composes this value with a `PIso`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PPrism` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PIso<A, B, C, D>) -> PPrism<S, T, C, D> {
        return self.compose(other.asPrism)
    }

    /// Composes this value with a `PLens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `POptional` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PLens<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.asOptional.compose(other)
    }

    /// Composes this value with a `POptional`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `POptional` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.asOptional.compose(other)
    }

    /// Composes this value with a `PSetter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.asSetter.compose(other)
    }

    /// Composes this value with a `Fold`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public func compose<C>(_ other: Fold<A, C>) -> Fold<S, C> {
        return self.asFold.compose(other)
    }

    /// Composes this value with a `PTraversal`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.asTraversal.compose(other)
    }

    /// Converts this value into a POptional.
    public var asOptional: POptional<S, T, A, B> {
        return POptional(set: self.set, getOrModify: self.getOrModify)
    }

    /// Converts this value into a PSetter.
    public var asSetter: PSetter<S, T, A, B> {
        return PSetter(modify: { f in {s in self.modify(s, f) } })
    }

    /// Converts this value into a Fold.
    public var asFold: Fold<S, A> {
        return PrismFold(prism: self)
    }

    /// Converts this value into a PTraversal.
    public var asTraversal: PTraversal<S, T, A, B> {
        return PrismTraversal(prism: self)
    }
}

public extension Prism where S == A, S == T, A == B {
    /// Provides an identity Prism.
    static var identity: Prism<S, S> {
        return Iso<S, S>.identity.asPrism
    }
}

public extension Prism where A: Equatable {
    /// Provides a prism that checks equality with a value.
    ///
    /// - Parameter a: Value to check equality with.
    /// - Returns: A Prism that only matches with the provided value.
    static func only(_ a: A) -> Prism<A, ()> {
        return Prism<A, ()>(getOrModify: { x in a == x ? Either.left(a) : Either.right(unit)},
                            reverseGet: { _ in a })
    }
}

private class PrismFold<S, T, A, B> : Fold<S, A> {
    private let prism: PPrism<S, T, A, B>

    init(prism: PPrism<S, T, A, B>) {
        self.prism = prism
    }

    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        return Option.fix(prism.getOption(s).map(f)).getOrElse(R.empty())
    }
}

private class PrismTraversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let prism : PPrism<S, T, A, B>

    init(prism: PPrism<S, T, A, B>) {
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
