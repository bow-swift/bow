import Foundation
import Bow

/// Witness for the `PAffineTraversal<S, T, A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForPAffineTraversal {}

/// Partial application of the PAffineTraversal type constructor, omitting the last parameter.
public final class PAffineTraversalPartial<S, T, A>: Kind3<ForPAffineTraversal, S, T, A> {}

/// Higher Kinded Type alias to improve readability over `Kind4<ForPAffineTraversal, S, T, A, B>`
public typealias PAffineTraversalOf<S, T, A, B> = Kind<PAffineTraversalPartial<S, T, A>, B>

/// AffineTraversal is a type alias for `PAffineTraversal` which fixes the type arguments and restricts the `PAffineTraversal` to monomorphic updates.
public typealias AffineTraversal<S, A> = PAffineTraversal<S, S, A, A>

/// Witness for the `AffineTraversal<S, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForAffineTraversal = ForPAffineTraversal

/// Partial application of the AffineTraversal type constructor, omitting the last parameter.
public typealias AffineTraversalPartial<S> = Kind<ForAffineTraversal, S>

/// An AffineTraversal is an optic that allows to see into a structure and getting, setting or modifying an optional focus.
///
/// A (polymorphic) PAffineTraversal is useful when setting or modifying a value for a type with an optional polymorphic focus.
///
/// A PAffineTraversal can be seen as a weaker `Lens` and `Prism` and combines their weakest functions:
///     - `set` meaning we can focus into an `S` and set a value `B` for a target `A` and obtain a modified source `T`.
///     - `getOrModify` meaning it returns the focus of a `PAffineTraversal` (if present) or the original value.
///
/// Type parameters:
///     - `S`: Source.
///     - `T`: Modified source.
///     - `A`: Focus.
///     - `B`: Modified focus.
public class PAffineTraversal<S, T, A, B>: PAffineTraversalOf<S, T, A, B> {
    private let setFunc: (S, B) -> T
    private let getOrModifyFunc: (S) -> Either<T, A>
    
    /// Composes a `PAffineTraversal` with a `PAffineTraversal`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PAffineTraversal<S, T, A, B>, rhs: PAffineTraversal<A, B, C, D>) -> PAffineTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PAffineTraversal` with a `PPrism`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PAffineTraversal<S, T, A, B>, rhs: PPrism<A, B, C, D>) -> PAffineTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PAffineTraversal` with a `PLens`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PAffineTraversal<S, T, A, B>, rhs: PLens<A, B, C, D>) -> PAffineTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PAffineTraversal` with a `PIso`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PAffineTraversal<S, T, A, B>, rhs: PIso<A, B, C, D>) -> PAffineTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PAffineTraversal` with a `PSetter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PAffineTraversal<S, T, A, B>, rhs: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PAffineTraversal` with a `Getter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: PAffineTraversal<S, T, A, B>, rhs: Getter<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PAffineTraversal` with a `Fold`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: PAffineTraversal<S, T, A, B>, rhs: Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PAffineTraversal` with a `PTraversal`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PAffineTraversal<S, T, A, B>, rhs: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Provides an AffineTraversal that never sees its focus.
    public static var void: AffineTraversal<S, A> {
        return AffineTraversal(set: { s, _ in s }, getOrModify: { s in Either<S, A>.left(s) })
    }
    
    /// Initializes a PAffineTraversal.
    ///
    /// - Parameters:
    ///   - set: Setter function.
    ///   - getOrModify: Getter function.
    public init(set: @escaping (S, B) -> T, getOrModify: @escaping (S) -> Either<T, A>) {
        self.setFunc = set
        self.getOrModifyFunc = getOrModify
    }
    
    /// Gets a modified source.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - b: Modified focus.
    /// - Returns: Modified source.
    public func set(_ s: S, _ b: B) -> T {
        return setFunc(s, b)
    }
    
    /// Gets the focus or the modified source.
    ///
    /// - Parameter s: Source.
    /// - Returns: Either the focus or the modified source.
    public func getOrModify(_ s: S) -> Either<T, A> {
        return getOrModifyFunc(s)
    }
    
    /// Modifies the focus of a PAffineTraversal with an `Applicative` function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: Modified source in the context of the `Applicative`.
    public func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return getOrModify(s).fold(F.pure, { a in F.map(f(a)){ b in self.set(s, b) } })
    }
    
    /// Lifts an `Applicative` function operating on the focus to one operating on the source.
    ///
    /// - Parameter f: Modifying function.
    /// - Returns: Lifted function in the context of the source.
    public func liftF<F: Applicative>(_ f: @escaping (A) -> Kind<F, B>) -> (S) -> Kind<F, T> {
        return { s in self.modifyF(s, f) }
    }
    
    /// Gets the focus or `Option.none` if it is not present.
    ///
    /// - Parameter s: Source.
    /// - Returns: Focus or `Option.none` if it is not present.
    public func getOption(_ s: S) -> Option<A> {
        return getOrModify(s).toOption()
    }
    
    /// Gets the focus or `nil` if it is not present.
    ///
    /// - Parameter s: Source.
    /// - Returns: Focus or `nil` if it is not present.
    public func getOptional(_ s: S) -> A? {
        getOption(s).toOptional()
    }
    
    /// Sets a new value for the focus.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - b: New focus.
    /// - Returns: Optional modified source.
    public func setOption(_ s: S, _ b: B) -> Option<T> {
        return modifyOption(s, constant(b))
    }
    
    /// Sets a new value for the focus.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - b: New focus.
    /// - Returns: Optional modified source.
    public func setOptional(_ s: S, _ b: B) -> T? {
        setOption(s, b).toOptional()
    }
    
    /// Checks if the provided source is empty (i.e. does not have a focus).
    ///
    /// - Parameter s: Source.
    /// - Returns: Boolean value indicating if the source is empty.
    public func isEmpty(_ s: S) -> Bool {
        return !nonEmpty(s)
    }
    
    /// Checks if the provided source is non-empty (i.e. does have a focus).
    ///
    /// - Parameter s: Source.
    /// - Returns: Boolean value indicating if the source is non-empty.
    public func nonEmpty(_ s: S) -> Bool {
        return getOption(s).fold(constant(false), constant(true))
    }
    
    /// Joins with a PAffineTraversal with the same focus.
    ///
    /// - Parameter other: Value to join with.
    /// - Returns: A PAffineTraversal that operates in either of the original sources.
    public func choice<S1, T1>(_ other: PAffineTraversal<S1, T1, A, B>) -> PAffineTraversal<Either<S, S1>, Either<T, T1>, A, B> {
        return PAffineTraversal<Either<S, S1>, Either<T, T1>, A, B>(set: { either, b in
            either.bimap({ s in self.set(s, b) }, { s in other.set(s, b) })
        }, getOrModify: { either in
            either.fold({ s in self.getOrModify(s).bimap(Either.left, id) },
                        { s in other.getOrModify(s).bimap(Either.right, id) })
        })
    }
    
    /// Pairs this `PAffineTraversal` with another type, placing this as the first element.
    ///
    /// - Returns: A `PAffineTraversal` that operates on tuples where the second argument remains unchanged.
    public func first<C>() -> PAffineTraversal<(S, C), (T, C), (A, C), (B, C)> {
        return PAffineTraversal<(S, C), (T, C), (A, C), (B, C)>(
            set: { sc, bc in self.setOption(sc.0, bc.0).fold({ (self.set(sc.0, bc.0), bc.1) }, { t in (t, sc.1) }) },
            getOrModify: { s, c in self.getOrModify(s).bimap({ t in (t, c) }, { a in (a, c) }) })
    }
    
    /// Pairs this `PAffineTraversal` with another type, placing this as the second element.
    ///
    /// - Returns: A `PAffineTraversal` that operates on tuples where the first argument remains unchanged.
    public func second<C>() -> PAffineTraversal<(C, S), (C, T), (C, A), (C, B)> {
        return PAffineTraversal<(C, S), (C, T), (C, A), (C, B)>(
            set: { cs, cb in self.setOption(cs.1, cb.1).fold({ (cs.0, self.set(cs.1, cb.1)) }, { t in (cb.0, t)}) },
            getOrModify: { c, s in self.getOrModify(s).bimap({ t in (c, t) }, { a in (c, a) })
        })
    }
    
    /// Modifies the focus with a function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: Modified source.
    public func modify(_ s: S, _ f: @escaping (A) -> B) -> T {
        return getOrModify(s).fold(id, { a in self.set(s, f(a)) })
    }
    
    /// Lifts a function modifying the focus to a function modifying the source.
    ///
    /// - Parameter f: Modifying function.
    /// - Returns: A function modifying the source.
    public func lift(_ f: @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }
    
    /// Modifies the source with a function if it matches.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: An optional modified source that is present if the modification took place.
    public func modifyOption(_ s: S, _ f : @escaping (A) -> B) -> Option<T> {
        return Option.fix(getOption(s).map { a in self.set(s, f(a)) })
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
    /// - Returns: A Boolean value indicating if the focus matches the predicate.
    public func exists(_ s: S, _ predicate: @escaping (A) -> Bool) -> Bool {
        return getOption(s).fold(constant(false), predicate)
    }
    
    /// Checks if the focus matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: A Boolean value indicating if the focus matches the predicate.
    public func all(_ s: S, _ predicate: @escaping (A) -> Bool) -> Bool {
        return getOption(s).fold(constant(true), predicate)
    }
    
    /// Composes this value with a `PAffineTraversal`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PAffineTraversal<A, B, C, D>) -> PAffineTraversal<S, T, C, D> {
        return PAffineTraversal<S, T, C, D>(
            set: { s, d in
                self.modify(s){ a in other.set(a, d) }
        },
            getOrModify: { s in
                Either.fix(self.getOrModify(s).flatMap { a in other.getOrModify(a).bimap({ t in self.set(s, t) }, id)})
        })
    }
    
    /// Composes this value with a `PPrism`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PPrism<A, B, C, D>) -> PAffineTraversal<S, T, C, D> {
        return self.compose(other.asAffineTraversal)
    }
    
    /// Composes this value with a `PLens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PLens<A, B, C, D>) -> PAffineTraversal<S, T, C, D> {
        return self.compose(other.asAffineTraversal)
    }
    
    /// Composes this value with a `PIso`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PIso<A, B, C, D>) -> PAffineTraversal<S, T, C, D> {
        return self.compose(other.asAffineTraversal)
    }
    
    /// Composes this value with a `PSetter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.asSetter.compose(other)
    }
    
    /// Composes this value with a `Getter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public func compose<C>(_ other: Getter<A, C>) -> Fold<S, C> {
        return self.asFold.compose(other)
    }
    
    /// Composes this value with a `PPrism`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public func compose<C>(_ other: Fold<A, C>) -> Fold<S, C> {
        return self.asFold.compose(other)
    }
    
    /// Composes this value with a `PTraversal`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PAffineTraversal` resulting from the sequential application of the two provided optics.
    public func compose<C, D>(_ other: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.asTraversal.compose(other)
    }
    
    /// Converts this value as a `PSetter`.
    public var asSetter: PSetter<S, T, A, B> {
        return PSetter(modify: { f in { s in self.modify(s, f) } })
    }
    
    /// Converts this value as a `Fold`.
    public var asFold: Fold<S, A> {
        return AffineTraversalFold(affineTraversal: self)
    }
    
    /// Converts this value as a `PTraversal`.
    public var asTraversal: PTraversal<S, T, A, B> {
        return AffineTraversalTraversal(affineTraversal: self)
    }
    
    /// Extracts the focus viewed through the `PAffineTraversal`.
    ///
    /// - Returns: A `State` of the source and target.
    public func extract() -> State<S, Option<A>> {
        return State { s in (s, self.getOption(s)) }
    }
    
    /// Extracts the focus viewed through the `PAffineTraversal`.
    ///
    /// - Returns: A `State` of the source and target.
    public func toState() -> State<S, Option<A>> {
        return extract()
    }
    
    /// Extracts the focus viewed through the `PAffineTraversal` and applies the provided function to it.
    ///
    /// - Returns: A `State` of the source and target, modified by the provided function.
    public func extractMap<C>(_ f: @escaping (A) -> C) -> State<S, Option<C>> {
        return extract().map { x in x.map(f)^ }^
    }
}

public extension AffineTraversal where S == T, A == B {
    /// Updates the focus viewed through the `AffineTraversal` and returns its new value.
    ///
    /// - Parameter f: Updating function.
    /// - Returns: A `State` with the new value.
    func update(_ f: @escaping (A) -> A) -> State<S, Option<A>> {
        return updateOld(f).map { x in x.map(f)^ }^
    }
    
    /// Updates the focus viewed through the `AffineTraversal` and returns its old value.
    ///
    /// - Parameter f: Updating function.
    /// - Returns: A `State` with the old value.
    func updateOld(_ f: @escaping (A) -> A) -> State<S, Option<A>> {
        return State { s in (self.modify(s, f), self.getOption(s)) }
    }
    
    /// Updates the focus viewed through the `AffineTraversal`, ignoring the result.
    ///
    /// - Parameter f: Updating function.
    /// - Returns: A `State` ignoring the result.
    func update_(_ f: @escaping (A) -> A) -> State<S, ()> {
        return State { s in (self.modify(s, f), ()) }
    }
    
    /// Assigns the focus viewed through the `AffineTraversal` and returns its new value.
    ///
    /// - Parameter a: Value to assign the focus.
    /// - Returns: A `State` with the new value.
    func assign(_ a: A) -> State<S, Option<A>> {
        return update(constant(a))
    }
    
    /// Assigns the focus viewed through the `AffineTraversal` and returns its old value.
    ///
    /// - Parameter a: Value to assign the focus.
    /// - Returns: A `State` with the old value.
    func assignOld(_ a: A) -> State<S, Option<A>> {
        return updateOld(constant(a))
    }
    
    /// Assigns the focus viewed through the `AffineTraversal`, ignoring the result.
    ///
    /// - Parameter a: Value to assign the focus.
    /// - Returns: A `State` ignoring the result.
    func assign_(_ a: A) -> State<S, ()> {
        return update_(constant(a))
    }
}

public extension AffineTraversal where S == A, S == T, A == B {
    /// Obtains an identity AffineTraversal.
    static var identity: AffineTraversal<S, S> {
        return Iso<S, S>.identity.asAffineTraversal
    }
    
    /// Obtains an AffineTraversal that takes either an `S` or an `S` and strips the choice of `S`.
    static var codiagonal: AffineTraversal<Either<S, S>, S> {
        return AffineTraversal<Either<S, S>, S>(
            set: { ess, s in ess.bimap(constant(s), constant(s)) },
            getOrModify: { ess in ess.fold(Either.right, Either.right) })
    }
}

private class AffineTraversalFold<S, T, A, B> : Fold<S, A> {
    private let affineTraversal: PAffineTraversal<S, T, A, B>
    
    init(affineTraversal: PAffineTraversal<S, T, A, B>) {
        self.affineTraversal = affineTraversal
    }
    
    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        return Option.fix(affineTraversal.getOption(s).map(f)).getOrElse(R.empty())
    }
}

private class AffineTraversalTraversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let affineTraversal: PAffineTraversal<S, T, A, B>
    
    init(affineTraversal: PAffineTraversal<S, T, A, B>) {
        self.affineTraversal = affineTraversal
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return self.affineTraversal.modifyF(s, f)
    }
}

extension AffineTraversal {
    internal var fix: AffineTraversal<S, A> {
        return self as! AffineTraversal<S, A>
    }
}
