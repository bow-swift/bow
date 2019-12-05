import Foundation
import Bow

/// Witness for the `PLens<S, T, A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForPLens {}

/// Partial application of the PLens type constructor, omitting the last parameter.
public final class PLensPartial<S, T, A>: Kind3<ForPLens, S, T, A> {}

/// Higher Kinded Type alias to improve readability over `Kind4<ForPLens, S, T, A, B>`
public typealias PLensOf<S, T, A, B> = Kind<PLensPartial<S, T, A>, B>

/// Lens is a type alias for `PLens` which fixes the type arguments and restricts the `PLens` to monomorphic updates.
public typealias Lens<S, A> = PLens<S, S, A, A>

/// Witness for the `Lens<S, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForLens = ForPLens

/// Partial application of the Lens type constructor, omitting the last parameter.
public typealias LensPartial<S> = Kind<ForLens, S>

/// A Lens (or Functional Reference) is an optic that can focus into a structure for getting, setting or modifying the focus (target).
///
/// A (polymorphic) PLens is useful when setting or modifying a value for a constructed type.
///
/// A PLens can be seen as a pair of functions:
///     - `get: (S) -> A` meaning we can focus into `S` and extract an `A`.
///     - `set: (B, S) -> T` meaning we can focus into an `S` and set a value `B` for a target `A` and obtain a modified source.
///
/// The type arguments are:
///     - `S` is the source of a PLens.
///     - `T` is the modified source of a PLens.
///     - `A` is the focus of a PLens.
///     - `B` is the modified focus of a PLens.
public class PLens<S, T, A, B>: PLensOf<S, T, A, B> {
    private let getFunc: (S) -> A
    private let setFunc: (S, B) -> T
    
    /// Composes a `PLens` with a `PLens`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PLens` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PLens<S, T, A, B>, rhs: PLens<A, B, C, D>) -> PLens<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PLens` with a `PIso`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PLens` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PLens<S, T, A, B>, rhs: PIso<A, B, C, D>) -> PLens<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PLens` with a `Getter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Getter` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: PLens<S, T, A, B>, rhs: Getter<A, C>) -> Getter<S, C> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PLens` with a `PPrism`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `POptional` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PLens<S, T, A, B>, rhs: PPrism<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PLens` with a `POptional`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `POptional` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PLens<S, T, A, B>, rhs: POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PLens` with a `PSetter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PLens<S, T, A, B>, rhs: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PLens` with a `Fold`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: PLens<S, T, A, B>, rhs: Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PLens` with a `PTraversal`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PLens<S, T, A, B>, rhs: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Initializes a `PLens` with its `get` and `set` functions.
    ///
    /// - Parameters:
    ///   - get: Getter function for the lens.
    ///   - set: Setter function for the lens.
    public init(get: @escaping (S) -> A, set: @escaping (S, B) -> T) {
        self.getFunc = get
        self.setFunc = set
    }
    
    /// Obtains the focus of this lens.
    ///
    /// - Parameter s: Source.
    /// - Returns: Focus for the provided source.
    public func get(_ s: S) -> A {
        return getFunc(s)
    }
    
    /// Sets the focus of this lens.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - b: Modified focus.
    /// - Returns: Modified source.
    public func set(_ s: S, _ b: B) -> T {
        return setFunc(s, b)
    }
    
    /// Modifies the focus of this lens using a `Functor` function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: Modified source in the context of the `Functor`.
    public func modifyF<F: Functor>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get(s)), { b in self.set(s, b) })
    }
    
    /// Lifts a `Functor` function between the targets to a function between the sources.
    ///
    /// - Parameter f: Modifying function between the targets.
    /// - Returns: A `Functor` function between the sources.
    public func liftF<F: Functor>(_ f: @escaping (A) -> Kind<F, B>) -> (S) -> Kind<F, T> {
        return { s in self.modifyF(s, f) }
    }
    
    /// Joins two lenses with the same focus.
    ///
    /// - Parameter other: A lens with the same focus as this one.
    /// - Returns: A lens whose source is a pair of the two original lenses.
    public func choice<S1, T1>(_ other: PLens<S1, T1, A, B>) -> PLens<Either<S, S1>, Either<T, T1>, A, B> {
        return PLens<Either<S, S1>, Either<T, T1>, A, B>(
            get: { either in either.fold(self.get, other.get) },
            set: { either, b in either.bimap({ s in self.set(s, b) }, { s1 in other.set(s1, b) }) })
    }
    
    /// Pairs two disjoint lenses.
    ///
    /// - Parameter other: A disjoint lens.
    /// - Returns: A lens that operates on tuples of the original and parameter sources and targets.
    public func split<S1, T1, A1, B1>(_ other: PLens<S1, T1, A1, B1>) -> PLens<(S, S1), (T, T1), (A, A1), (B, B1)> {
        return PLens<(S, S1), (T, T1), (A, A1), (B, B1)>(
            get: { (s, s1) in (self.get(s), other.get(s1)) },
            set: { (s, b) in (self.set(s.0, b.0), other.set(s.1, b.1)) })
    }
    
    /// Pairs this `PLens` with another type, placing this as the first element.
    ///
    /// - Returns: A `PLens` that operates on tuples where the second argument remains unchanged.
    public func first<C>() -> PLens<(S, C), (T, C), (A, C), (B, C)> {
        return PLens<(S, C), (T, C), (A, C), (B, C)>(
            get: { (s, c) in (self.get(s), c)},
            set: { (s, b) in (self.set(s.0, b.0), s.1) })
    }
    
    /// Pairs this `PLens` with another type, placing this as the second element.
    ///
    /// - Returns: A `PLens` that operates on tuples where the first argument remains unchanged.
    public func second<C>() -> PLens<(C, S), (C, T), (C, A), (C, B)> {
        return PLens<(C, S), (C, T), (C, A), (C, B)>(
            get: { (c, s) in (c, self.get(s)) },
            set: { (s, b) in (s.0, self.set(s.1, b.1)) })
    }
    
    /// Composes this lens with a `PLens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PLens` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PLens<A, B, C, D>) -> PLens<S, T, C, D> {
        return PLens<S, T, C, D>(
            get: self.get >>> other.get,
            set: { s, c in self.set(s, other.set(self.get(s), c)) })
    }
    
    /// Composes this lens with a `PIso`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PIso` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PIso<A, B, C, D>) -> PLens<S, T, C, D> {
        return compose(other.asLens)
    }
    
    /// Composes this lens with a `Getter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Getter` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Getter<A, C>) -> Getter<S, C> {
        return self.asGetter.compose(other)
    }
    
    /// Composes this lens with a `PPrism`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `POptional` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PPrism<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.asOptional.compose(other)
    }
    
    /// Composes this lens with a `POptional`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `POptional` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: POptional<A, B, C, D>) -> POptional<S, T, C, D> {
        return self.asOptional.compose(other)
    }
    
    /// Composes this lens with a `PSetter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.asSetter.compose(other)
    }
    
    /// Composes this lens with a `Fold`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Fold<A, C>) -> Fold<S, C> {
        return self.asFold.compose(other)
    }
    
    /// Composes this lens with a `PLens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.asTraversal.compose(other)
    }
    
    /// Obtains a `Getter` from this lens.
    public var asGetter: Getter<S, A> {
        return Getter(get: self.get)
    }
    
    /// Obtains a `POptional` from this lens.
    public var asOptional: POptional<S, T, A, B> {
        return POptional(
            set: self.set,
            getOrModify: self.get >>> Either.right)
    }
    
    /// Obtains a `PSetter` from this lens.
    public var asSetter: PSetter<S, T, A, B> {
        return PSetter(modify: { f in { s in self.modify(s, f) } })
    }
    
    /// Obtains a `Fold` from this lens.
    public var asFold: Fold<S, A> {
        return LensFold(lens: self)
    }
    
    /// Obtains a `PTraversal` from this lens.
    public var asTraversal: PTraversal<S, T, A, B> {
        return LensTraversal(lens: self)
    }
    
    /// Modifies the focus of this lens with the provided function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: Modified source.
    public func modify(_ s: S, _ f: @escaping (A) -> B) -> T {
        return set(s, f(get(s)))
    }
    
    /// Lifts a function that modifies the targets, to a function that modifies the sources.
    ///
    /// - Parameter f: Modifying function.
    /// - Returns: Function that modifies sources.
    public func lift(_ f: @escaping (A) -> B) -> (S) -> T {
        return { s in self.modify(s, f) }
    }
    
    /// Retrieves the target of this lens if it matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: An optional value that is present if the source matches the predicate.
    public func find(_ s: S, _ predicate: (A) -> Bool) -> Option<A> {
        let a = get(s)
        return predicate(a) ? Option.some(a) : Option.none()
    }
    
    /// Checks if the target of this lens matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: Boolean value indicating if the target of the provided source matches the predicate.
    public func exists(_ s: S, _ predicate: (A) -> Bool) -> Bool {
        return predicate(get(s))
    }
    
    /// Extracts the value viewed through the get function.
    ///
    /// - Returns: A `Reader` from source to target.
    public func ask() -> Reader<S, A> {
        return Reader(get >>> Id.pure)
    }
    
    /// Extracts the value viewed through the get function.
    ///
    /// - Returns: A `Reader` from source to target.
    public func toReader() -> Reader<S, A> {
        return ask()
    }
    
    /// Extracts the value viewed through the get function and applies the provided function to it.
    ///
    /// - Parameter f: Function to apply to the focus.
    /// - Returns: A `Reader` from source to the target modified by the provided function.
    public func asks<C>(_ f: @escaping (A) -> C) -> Reader<S, C> {
        return ask().map(f)^
    }
    
    /// Extracts the focus view through the `PLens`.
    ///
    /// - Returns: A `State` of the source and target.
    public func extract() -> State<S, A> {
        return State { s in (s, self.get(s)) }
    }
    
    /// Extracts the focus view through the `PLens`.
    ///
    /// - Returns: A `State` of the source and target.
    public func toState() -> State<S, A> {
        return extract()
    }
    
    /// Extracts the focus view through the `PLens` and applies the provided function to it.
    ///
    /// - Returns: A `State` of the source and target, modified by the provided function.
    public func extractMap<C>(_ f: @escaping (A) -> C) -> State<S, C> {
        return extract().map(f)^
    }
}

// MARK: Extensions for monomorphic Lens
public extension Lens where S == T, A == B {
    /// Updates the focus viewed through the `Lens` and returns its new value.
    ///
    /// - Parameter f: Updating function.
    /// - Returns: A `State` with the new value.
    func update(_ f: @escaping (A) -> A) -> State<S, A> {
        return State { s in
            let b = f(self.get(s))
            return (self.set(s, b), b)
        }
    }
    
    /// Updates the focus viewed through the `Lens` and returns its old value.
    ///
    /// - Parameter f: Updating function.
    /// - Returns: A `State` with the old value.
    func updateOld(_ f: @escaping (A) -> A) -> State<S, A> {
        return State { s in (self.modify(s, f), self.get(s)) }
    }
    
    /// Updates the focus viewed through the `Lens`, ignoring the result.
    ///
    /// - Parameter f: Updating function.
    /// - Returns: A `State` ignoring the result.
    func update_(_ f: @escaping (A) -> A) -> State<S, ()> {
        return State { s in (self.modify(s, f), ()) }
    }
    
    /// Assigns the focus viewed through the `Lens` and returns its new value.
    ///
    /// - Parameter a: Value to assign the focus.
    /// - Returns: A `State` with the new value.
    func assign(_ a: A) -> State<S, A> {
        return update(constant(a))
    }
    
    /// Assigns the focus viewed through the `Lens` and returns its old value.
    ///
    /// - Parameter a: Value to assign the focus.
    /// - Returns: A `State` with the old value.
    func assignOld(_ a: A) -> State<S, A> {
        return updateOld(constant(a))
    }
    
    /// Assigns the focus viewed through the `Lens`, ignoring the result.
    ///
    /// - Parameter a: Value to assign the focus.
    /// - Returns: A `State` ignoring the result.
    func assign_(_ a: A) -> State<S, ()> {
        return update_(constant(a))
    }
}

public extension Lens where S == A, S == T, A == B {
    /// Obtains an identity lens; i.e. a no-op lens.
    static var identity: Lens<S, S> {
        return Iso<S, S>.identity.asLens
    }
    
    /// Obtains a lens that receives either values of `S` and strips the choice of `S`.
    static var codiagonal: Lens<Either<S, S>, S> {
        return Lens<Either<S, S>, S>(
            get: { ess in ess.fold(id, id) },
            set: { ess, s in ess.bimap(constant(s), constant(s)) })
    }
}

public extension PLens where S == T {
    /// Combine this lens with another with the same source but different focus.
    ///
    /// - Parameter other: A lens with the same source but different focus.
    /// - Returns: A lens that lets us focus on the two foci at the same time.
    func merge<AA, BB>(_ other: PLens<S, S, AA, BB>) -> PLens<S, S, (A, AA), (B, BB)> {
        PLens<S, T, (A, AA), (B, BB)>(get: { s in (self.get(s), other.get(s)) },
                                      set: { s, b in other.set(self.set(s, b.0), b.1) }
        )
    }
}

private class LensFold<S, T, A, B> : Fold<S, A> {
    private let lens: PLens<S, T, A, B>
    
    init(lens: PLens<S, T, A, B>) {
        self.lens = lens
    }
    
    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        return f(lens.get(s))
    }
}

private class LensTraversal<S, T, A, B>: PTraversal<S, T, A, B> {
    private let lens: PLens<S, T, A, B>
    
    init(lens: PLens<S, T, A, B>) {
        self.lens = lens
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.lens.get(s)), { b in self.lens.set(s, b)})
    }
}
