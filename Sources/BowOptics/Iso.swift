import Foundation
import Bow

/// Witness for the `PIso<S, T, A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForPIso {}

/// Partial application of the PIso type constructor, omitting the last parameter.
public final class PIsoPartial<S, T, A>: Kind3<ForPIso, S, T, A> {}

/// Higher Kinded Type alias to improve readability over Kind4<ForPIso, S, T, A, B>
public typealias PIsoOf<S, T, A, B> = Kind<PIsoPartial<S, T, A>, B>

/// `Iso` is a type alias for `PIso` which fixes the type arguments and restricts the `PIso` to monomorphic updates.
public typealias Iso<S, A> = PIso<S, S, A, A>

/// Witness for the `Iso<S, A>`data type. To be used in simulated Higher Kinded Types.
public typealias ForIso = ForPIso

/// Higher Kinded Type alias to improve readability over Kind4<ForPIso, S, S, A, A>
public typealias IsoOf<S, A> = PIsoOf<S, S, A, A>

/// Partial application of the Iso type constructor, omitting the last parameter.
public typealias IsoPartial<S> = Kind<ForIso, S>

/// An Iso is a loss less invertible optic that defines an isomorphism between a type `S` and `A`.
///
/// A polimorphic `PIso` is useful when setting or modifying a value for a constructed type; e.g. `PIso<<Option<Int>, Option<String>, Int?, String?>`.
///
/// - `S`: Source of a `PIso`.
/// - `T`: Modified source of a `PIso`.
/// - `A`: Focus of a `PIso`.
/// - `B`: Modified target of a `PIso`.
public class PIso<S, T, A, B>: PIsoOf<S, T, A, B> {
    private let getFunc: (S) -> A
    private let reverseGetFunc: (B) -> T

    /// Composes two `PIso`s.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PIso` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PIso<S, T, A, B>, rhs: PIso<A, B, C, D>) -> PIso<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PIso` with a `Getter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Getter` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: PIso<S, T, A, B>, rhs: Getter<A, C>) -> Getter<S, C> {
        return lhs.compose(rhs)
    }

    /// Composes a `PIso` with a `PLens`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PLens` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PIso<S, T, A, B>, rhs: PLens<A, B, C, D>) -> PLens<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PIso` with a `PPrism`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PPrism` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PIso<S, T, A, B>, rhs: PPrism<A, B, C, D>) -> PPrism<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PIso` with a `POptional`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `POptional` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PIso<S, T, A, B>, rhs: POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PIso` with a `PSetter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PIso<S, T, A, B>, rhs: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Composes a `PIso` with a `Fold`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: PIso<S, T, A, B>, rhs: Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }

    /// Composes a `PIso` with a `PTraversal`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PIso<S, T, A, B>, rhs: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }

    /// Creates a `PIso` with two functions that form an isomorphism.
    ///
    /// - Parameters:
    ///   - get: A function from the source to the focus.
    ///   - reverseGet: A function from the modified target to the modified focus.
    public init(get: @escaping (S) -> A, reverseGet: @escaping (B) -> T) {
        self.getFunc = get
        self.reverseGetFunc = reverseGet
    }

    /// Gets the focus of an Iso.
    ///
    /// - Parameter s: Source.
    /// - Returns: Focus of the provided source.
    public func get(_ s: S) -> A {
        return getFunc(s)
    }

    /// Gets the modified source of an Iso.
    ///
    /// - Parameter b: Modified target.
    /// - Returns: Modified source of the provided modified target.
    public func reverseGet(_ b: B) -> T {
        return reverseGetFunc(b)
    }

    /// Lifts this `PIso` to a `Functor` level.
    ///
    /// - Returns: A `PIso` that operates on the same type arguments but lifted to a `Functor`.
    public func mapping<F: Functor>() -> PIso<Kind<F, S>, Kind<F, T>, Kind<F, A>, Kind<F, B>> {
        return PIso<Kind<F, S>, Kind<F, T>, Kind<F, A>, Kind<F, B>>(get: { fs in
            F.map(fs, self.get)
        }, reverseGet: { fb in
            F.map(fb, self.reverseGet)
        })
    }

    /// Modify the target of a `PIso` with a `Functor` function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Function providing a modified target at the `Functor` level.
    /// - Returns: Modified source at the `Functor` level.
    public func modifyF<F: Functor>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(get(s)), self.reverseGet)
    }

    /// Lifts a function with a `Functor`.
    ///
    /// - Parameter f: Function with a `Functor` from focus to modified target.
    /// - Returns: Function with a `Functor` from source to modified source.
    public func liftF<F: Functor>(_ f: @escaping (A) -> Kind<F, B>) -> (S) -> Kind<F, T> {
        return { s in
            F.map(f(self.get(s)), self.reverseGet)
        }
    }

    /// Reverses the source and focus of this `PIso`.
    ///
    /// - Returns: A `PIso` with reversed source and focus.
    public func reverse() -> PIso<B, A, T, S> {
        return PIso<B, A, T, S>(get: self.reverseGet, reverseGet: self.get)
    }

    /// Checks if the focus statisfies a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: A present option with the focus, if it satisfies the predicate; or none, otherwise.
    public func find(_ s: S, _ predicate: (A) -> Bool) -> Option<A> {
        let a = get(s)
        return predicate(a) ? Option.some(a) : Option.none()
    }

    /// Sets the focus of a `PIso`.
    ///
    /// - Parameter b: Focus.
    /// - Returns: Source for the provided focus.
    public func set(_ b: B) -> T {
        return reverseGet(b)
    }

    /// Pairs two disjoint `PIso`.
    ///
    /// - Parameter other: A disjoint `PIso` to pair with this one.
    /// - Returns: A `PIso` that operates on tuples corresponding to the two joined `PIso`.
    public func split<S1, T1, A1, B1>(_ other: PIso<S1, T1, A1, B1>) -> PIso<(S, S1), (T, T1), (A, A1), (B, B1)> {
        return PIso<(S, S1), (T, T1), (A, A1), (B, B1)>(
            get: { (s, s1) in (self.get(s), other.get(s1)) },
            reverseGet: { (b, b1) in (self.reverseGet(b), other.reverseGet(b1)) })
    }

    /// Pairs this `PIso` with another type, placing this as the first element.
    ///
    /// - Returns: A `PIso` that operates on tuples where the second argument remains unchanged.
    public func first<C>() -> PIso<(S, C), (T, C), (A, C), (B, C)> {
        return PIso<(S, C), (T, C), (A, C), (B, C)>(
            get: { (s, c) in (self.get(s), c) },
            reverseGet: { (b, c) in (self.reverseGet(b), c) })
    }

    /// Pairs this `PIso` with another type, placing this as the second element.
    ///
    /// - Returns: A `PIso` that operates on tuples where the first argument remains unchaged.
    public func second<C>() -> PIso<(C, S), (C, T), (C, A), (C, B)> {
        return PIso<(C, S), (C, T), (C, A), (C, B)>(
            get: { (c, s) in (c, self.get(s)) },
            reverseGet: { (c, b) in (c, self.reverseGet(b)) })
    }

    /// Creates the sum of this `PIso` with another type, placing this as the left side.
    ///
    /// - Returns: A `PIso` that operates on `Either`s where the right side remains unchanged.
    public func left<C>() -> PIso<Either<S, C>, Either<T, C>, Either<A, C>, Either<B, C>> {
        return PIso<Either<S, C>, Either<T, C>, Either<A, C>, Either<B, C>>(
            get: { either in either.bimap(self.get, id) },
            reverseGet: { either in either.bimap(self.reverseGet, id) })
    }

    /// Creates the sum of this `PIso` with another type, placing this as the right side.
    ///
    /// - Returns: A `PIso` that operates on `Either`s where the left side remains unchaged.
    public func right<C>() -> PIso<Either<C, S>, Either<C, T>, Either<C, A>, Either<C, B>> {
        return PIso<Either<C, S>, Either<C, T>, Either<C, A>, Either<C, B>>(
            get: { either in either.bimap(id, self.get) },
            reverseGet: { either in either.bimap(id, self.reverseGet) })
    }

    /// Composes this with a `PIso`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PIso` resulting from applying the two optics sequentially.
    public func compose<C, D>(_ other: PIso<A, B, C, D>) -> PIso<S, T, C, D> {
        return PIso<S, T, C, D>(get: self.get >>> other.get, reverseGet: other.reverseGet >>> self.reverseGet)
    }

    /// Composes this with a `Getter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Getter` resulting from applying the two optics sequentially.
    public func compose<C>(_ other: Getter<A, C>) -> Getter<S, C> {
        return self.asGetter.compose(other)
    }

    /// Composes this with a `PLens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PLens` resulting from applying the two optics sequentially.
    public func compose<C, D>(_ other: PLens<A, B, C, D>) -> PLens<S, T, C, D> {
        return self.asLens.compose(other)
    }

    /// Composes this with a `PPrism`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PPrism` resulting from applying the two optics sequentially.
    public func compose<C, D>(_ other: PPrism<A, B, C, D>) -> PPrism<S, T, C, D> {
        return self.asPrism.compose(other)
    }

    /// Composes this with a `POptional`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `POptional` resulting from applying the two optics sequentially.
    public func compose<C, D>(_ other: POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.asOptional.compose(other)
    }

    /// Composes this with a `PSetter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from applying the two optics sequentially.
    public func compose<C, D>(_ other: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.asSetter.compose(other)
    }

    /// Composes this with a `Fold`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from applying the two optics sequentially.
    public func compose<C>(_ other: Fold<A, C>) -> Fold<S, C> {
        return self.asFold.compose(other)
    }

    /// Composes this with a `PTraversal`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PTraversal` resulting from applying the two optics sequentially.
    public func compose<C, D>(_ other: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.asTraversal.compose(other)
    }

    /// Converts this into a `Getter`.
    public var asGetter: Getter<S, A> {
        return Getter(get: self.get)
    }

    /// Converts this into a `PLens`.
    public var asLens: PLens<S, T, A, B> {
        return PLens(get: self.get, set: { _, b in self.set(b) })
    }

    /// Converts this into a `PPrism`.
    public var asPrism: PPrism<S, T, A, B> {
        return PPrism(getOrModify: { s in Either.right(self.get(s)) }, reverseGet: self.reverseGet)
    }

    /// Converts this into a `POptional`.
    public var asOptional: POptional<S, T, A, B> {
        return POptional(set: { _, b in self.set(b) }, getOrModify: self.get >>> Either.right)
    }

    /// Converts this into a `PSetter`.
    public var asSetter: PSetter<S, T, A, B> {
        return PSetter(modify: { f in { s in self.modify(s, f) } })
    }

    /// Converts this into a `Fold`.
    public var asFold: Fold<S, A> {
        return IsoFold(iso: self)
    }

    /// Converts this into a `PTraversal`.
    public var asTraversal: PTraversal<S, T, A, B> {
        return IsoTraversal(iso: self)
    }

    /// Checks if the target fulfils a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: A boolean value indicating if the target matches the provided predicate.
    public func exists(_ s: S, _ predicate: (A) -> Bool) -> Bool {
        return predicate(get(s))
    }

    /// Modifies the focus with a function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Function modifying the focus.
    /// - Returns: Modified target.
    public func modify(_ s: S, _ f: @escaping (A) -> B) -> T {
        return reverseGet(f(get(s)))
    }

    /// Lifts a function to modify the focus.
    ///
    /// - Parameter f: Function modifying the focus.
    /// - Returns: Function from source to modified source.
    public func lift(_ f: @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }
}

public extension Iso where S == A, S == T, A == B {
    /// Provides an identity `Iso`.
    static var identity: Iso<S, S> {
        return Iso<S, S>(get: id, reverseGet: id)
    }
}

private class IsoFold<S, T, A, B>: Fold<S, A> {
    private let iso: PIso<S, T, A, B>

    init(iso: PIso<S, T, A, B>) {
        self.iso = iso
    }

    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        return f(iso.get(s))
    }
}

private class IsoTraversal<S, T, A, B>: PTraversal<S, T, A, B> {
    private let iso: PIso<S, T, A, B>

    init(iso: PIso<S, T, A, B>) {
        self.iso = iso
    }

    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(iso.get(s)), iso.reverseGet)
    }
}

extension Iso {
    internal var fix: Iso<S, A> {
        return self as! Iso<S, A>
    }
}
