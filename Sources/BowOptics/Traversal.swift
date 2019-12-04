import Foundation
import Bow

/// Witness for the `PTraversal<S, T, A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForPTraversal {}

/// Partial application of the PTraversal type constructor, omitting the last parameter.
public final class PTraversalPartial<S, T, A>: Kind3<ForPTraversal, S, T, A> {}

/// Higher Kinded Type alias to improve readability over Kind4<ForPIso, S, T, A, B>.
public typealias PTraversalOf<S, T, A, B> = Kind<PTraversalPartial<S, T, A>, B>

/// Traversal is a type alias for PTraversal which fixes the type arguments and restricts the PTraversal to monomorphic updates.
public typealias Traversal<S, A> = PTraversal<S, S, A, A>

/// Witness for the `Traversal<S, A>` data type. To be used in simulated Higher Kinded Types.
public typealias ForTraversal = ForPTraversal

/// Higher Kinded Type alias to imprope readability over Kind4<ForPTraversal, S, S, A, A>
public typealias TraversalOf<S, A> = PTraversalOf<S, S, A, A>

/// Partial application of the Traversal type constructor, omitting the last parameter.
public typealias TraversalPartial<S> = Kind<ForPTraversal, S>

/// A Traversal is an optic that allows to see into a structure with 0 to N foci.
///
/// Traversal is a generalization of `Traverse` and can be seen as a representation of `modifyF`. All methods are written in terms of `modifyF`.
///
/// Type parameters:
///     - `S`: Source.
///     - `T`: Modified source.
///     - `A`: Focus.
///     - `B`: Modified focus.
open class PTraversal<S, T, A, B>: PTraversalOf<S, T, A, B> {
    
    /// Modifies the source wiht an `Applicative` function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: Modified source in the context of the `Applicative`.
    open func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        fatalError("modifyF must be implemented in subclasses")
    }
    
    /// Provides a Traversal with no focus.
    public static var void: Traversal<S, A> {
        return Optional<S, A>.void.asTraversal
    }
    
    /// Provides a Traversal based on the implementation of `Traverse` for `F`.
    ///
    /// - Returns: A Traversal based on the implementation of `Traverse` for `F`.
    public static func fromTraverse<F: Traverse>() -> PTraversal<Kind<F, A>, Kind<F, B>, A, B> where S: Kind<F, A>, T: Kind<F, B> {
        return TraverseTraversal()
    }
    
    /// Creates a Traversal from multiple getters of the same source.
    ///
    /// - Parameters:
    ///   - get1: 1st getter.
    ///   - get2: 2nd getter.
    ///   - set: Setter.
    /// - Returns: A Traversal from the provided getters and setter.
    public static func from(_ get1: @escaping (S) -> A,
                            _ get2: @escaping (S) -> A,
                            _ set: @escaping (B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get2Traversal(get1: get1,
                             get2: get2,
                             set: set)
    }
    
    /// Creates a Traversal from multiple getters of the same source.
    ///
    /// - Parameters:
    ///   - get1: 1st getter.
    ///   - get2: 2nd getter.
    ///   - get3: 3rd getter.
    ///   - set: Setter.
    /// - Returns: A Traversal from the provided getters and setter.
    public static func from(_ get1: @escaping (S) -> A,
                            _ get2: @escaping (S) -> A,
                            _ get3: @escaping (S) -> A,
                            _ set: @escaping (B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get3Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             set: set)
    }
    
    /// Creates a Traversal from multiple getters of the same source.
    ///
    /// - Parameters:
    ///   - get1: 1st getter.
    ///   - get2: 2nd getter.
    ///   - get3: 3rd getter.
    ///   - get4: 4th getter.
    ///   - set: Setter.
    /// - Returns: A Traversal from the provided getters and setter.
    public static func from(_ get1: @escaping (S) -> A,
                            _ get2: @escaping (S) -> A,
                            _ get3: @escaping (S) -> A,
                            _ get4: @escaping (S) -> A,
                            _ set: @escaping (B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get4Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             set: set)
    }
    
    /// Creates a Traversal from multiple getters of the same source.
    ///
    /// - Parameters:
    ///   - get1: 1st getter.
    ///   - get2: 2nd getter.
    ///   - get3: 3rd getter.
    ///   - get4: 4th getter.
    ///   - get5: 5th getter.
    ///   - set: Setter.
    /// - Returns: A Traversal from the provided getters and setter.
    public static func from(_ get1: @escaping (S) -> A,
                            _ get2: @escaping (S) -> A,
                            _ get3: @escaping (S) -> A,
                            _ get4: @escaping (S) -> A,
                            _ get5: @escaping (S) -> A,
                            _ set: @escaping (B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get5Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             set: set)
    }
    
    /// Creates a Traversal from multiple getters of the same source.
    ///
    /// - Parameters:
    ///   - get1: 1st getter.
    ///   - get2: 2nd getter.
    ///   - get3: 3rd getter.
    ///   - get4: 4th getter.
    ///   - get5: 5th getter.
    ///   - get6: 6th getter.
    ///   - set: Setter.
    /// - Returns: A Traversal from the provided getters and setter.
    public static func from(_ get1: @escaping (S) -> A,
                            _ get2: @escaping (S) -> A,
                            _ get3: @escaping (S) -> A,
                            _ get4: @escaping (S) -> A,
                            _ get5: @escaping (S) -> A,
                            _ get6: @escaping (S) -> A,
                            _ set : @escaping (B, B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get6Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             get6: get6,
                             set: set)
    }
    
    /// Creates a Traversal from multiple getters of the same source.
    ///
    /// - Parameters:
    ///   - get1: 1st getter.
    ///   - get2: 2nd getter.
    ///   - get3: 3rd getter.
    ///   - get4: 4th getter.
    ///   - get5: 5th getter.
    ///   - get6: 6th getter.
    ///   - get7: 7th getter.
    ///   - set: Setter.
    /// - Returns: A Traversal from the provided getters and setter.
    public static func from(_ get1: @escaping (S) -> A,
                            _ get2: @escaping (S) -> A,
                            _ get3: @escaping (S) -> A,
                            _ get4: @escaping (S) -> A,
                            _ get5: @escaping (S) -> A,
                            _ get6: @escaping (S) -> A,
                            _ get7: @escaping (S) -> A,
                            _ set: @escaping (B, B, B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get7Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             get6: get6,
                             get7: get7,
                             set: set)
    }
    
    /// Creates a Traversal from multiple getters of the same source.
    ///
    /// - Parameters:
    ///   - get1: 1st getter.
    ///   - get2: 2nd getter.
    ///   - get3: 3rd getter.
    ///   - get4: 4th getter.
    ///   - get5: 5th getter.
    ///   - get6: 6th getter.
    ///   - get7: 7th getter.
    ///   - get8: 8th getter.
    ///   - set: Setter.
    /// - Returns: A Traversal from the provided getters and setter.
    public static func from(_ get1: @escaping (S) -> A,
                            _ get2: @escaping (S) -> A,
                            _ get3: @escaping (S) -> A,
                            _ get4: @escaping (S) -> A,
                            _ get5: @escaping (S) -> A,
                            _ get6: @escaping (S) -> A,
                            _ get7: @escaping (S) -> A,
                            _ get8: @escaping (S) -> A,
                            _ set: @escaping (B, B, B, B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get8Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             get6: get6,
                             get7: get7,
                             get8: get8,
                             set: set)
    }
    
    /// Creates a Traversal from multiple getters of the same source.
    ///
    /// - Parameters:
    ///   - get1: 1st getter.
    ///   - get2: 2nd getter.
    ///   - get3: 3rd getter.
    ///   - get4: 4th getter.
    ///   - get5: 5th getter.
    ///   - get6: 6th getter.
    ///   - get7: 7th getter.
    ///   - get8: 8th getter.
    ///   - get9: 9th getter.
    ///   - set: Setter.
    /// - Returns: A Traversal from the provided getters and setter.
    public static func from(_ get1: @escaping (S) -> A,
                            _ get2: @escaping (S) -> A,
                            _ get3: @escaping (S) -> A,
                            _ get4: @escaping (S) -> A,
                            _ get5: @escaping (S) -> A,
                            _ get6: @escaping (S) -> A,
                            _ get7: @escaping (S) -> A,
                            _ get8: @escaping (S) -> A,
                            _ get9: @escaping (S) -> A,
                            _ set: @escaping (B, B, B, B, B, B, B, B, B, S) -> T) -> PTraversal<S, T, A, B> {
        return Get9Traversal(get1: get1,
                             get2: get2,
                             get3: get3,
                             get4: get4,
                             get5: get5,
                             get6: get6,
                             get7: get7,
                             get8: get8,
                             get9: get9,
                             set: set)
    }
    
    /// Composes a `PTraversal` with a `PTraversal`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PTraversal<S, T, A, B>, rhs: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PTraversal` with a `PSetter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PSetter` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PTraversal<S, T, A, B>, rhs: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PTraversal` with a `Fold`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: PTraversal<S, T, A, B>, rhs: Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PTraversal` with a `POptional`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PTraversal<S, T, A, B>, rhs: POptional<A, B, C, D>) -> PTraversal<S, T, C, D>{
        return lhs.compose(rhs)
    }
    
    /// Composes a `PTraversal` with a `PPrism`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PTraversal<S, T, A, B>, rhs: PPrism<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PTraversal` with a `PLens`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PTraversal<S, T, A, B>, rhs: PLens<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `PTraversal` with a `PIso`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two provided optics.
    public static func +<C, D>(lhs: PTraversal<S, T, A, B>, rhs: PIso<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return lhs.compose(rhs)
    }
    
    /// Transforms all foci in this Traversal and folds them using their `Monoid` instance.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Transforming function.
    /// - Returns: A summary value of the transformation and folding.
    public func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R  {
        return Const.fix(self.modifyF(s, { b in Const<R, B>(f(b)) })).value
    }
    
    /// Obtains all foci.
    ///
    /// - Parameter s: Source
    /// - Returns: An `ArrayK` with all foci.
    public func getAll(_ s: S) -> ArrayK<A> {
        return ArrayK.fix(foldMap(s, { a in ArrayK([a]) }))
    }
    
    /// Sets a new focus.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - b: Modified focus.
    /// - Returns: Modified source.
    public func set(_ s: S, _ b: B) -> T {
        return modify(s, constant(b))
    }
    
    /// Counts the number of foci.
    ///
    /// - Parameter s: Source.
    /// - Returns: Number of foci in this Traversal.
    public func size(_ s: S) -> Int {
        return foldMap(s, constant(1))
    }
    
    /// Checks if this Traversal has any focus.
    ///
    /// - Parameter s: Source.
    /// - Returns: True if this Traversal do not have any focus; false otherwise.
    public func isEmpty(_ s: S) -> Bool {
        return foldMap(s, constant(false))
    }
    
    /// Checks if this Traversal has any focus.
    ///
    /// - Parameter s: Source.
    /// - Returns: False if this Traversal do not have any focus; true otherwise.
    public func nonEmpty(_ s: S) -> Bool {
        return !isEmpty(s)
    }
    
    /// Retrieves the first focus of this Traversal, if any.
    ///
    /// - Parameter s: Source.
    /// - Returns: An optional value with the first focus of the source, if any.
    public func headOption(_ s: S) -> Option<A> {
        return foldMap(s, FirstOption.init).const.value
    }
    
    /// Retrieves the last focus of this Traversal, if any.
    ///
    /// - Parameter s: Source.
    /// - Returns: An optional value with the last focus of the source, if any.
    public func lastOption(_ s: S) -> Option<A> {
        return foldMap(s, LastOption.init).const.value
    }
    
    /// Joins two Traversal with the same focus.
    ///
    /// - Parameter other: Value to join with.
    /// - Returns: A Traversal that operates on either of the original sources.
    public func choice<U, V>(_ other: PTraversal<U, V, A, B>) -> PTraversal<Either<S, U>, Either<T, V>, A, B> {
        return ChoiceTraversal(first: self, second: other)
    }
    
    /// Composes this with a `PTraversal`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PTraversal<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return ComposeTraversal(first: self, second: other)
    }
    
    /// Composes this with a `PSetter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PSetter` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PSetter<A, B, C, D>) -> PSetter<S, T, C, D> {
        return self.asSetter.compose(other)
    }
    
    /// Composes this with a `Fold`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of the two optics.
    public func compose<C>(_ other: Fold<A, C>) -> Fold<S, C> {
        return self.asFold.compose(other)
    }
    
    /// Composes this with a `POptional`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: POptional<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.compose(other.asTraversal)
    }
    
    /// Composes this with a `PPrism`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PPrism<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.compose(other.asTraversal)
    }
    
    /// Composes this with a `PLens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PLens<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.compose(other.asTraversal)
    }
    
    /// Composes this with a `PIso`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `PTraversal` resulting from the sequential application of the two optics.
    public func compose<C, D>(_ other: PIso<A, B, C, D>) -> PTraversal<S, T, C, D> {
        return self.compose(other.asTraversal)
    }
    
    /// Converts this to a `PSetter`.
    public var asSetter: PSetter<S, T, A, B> {
        return PSetter(modify: { f in { s in self.modify(s, f) } })
    }
    
    /// Converts this to a `Fold`.
    public var asFold: Fold<S, A> {
        return TraversalFold(traversal: self)
    }
    
    /// Obtains the first focus that matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: An optional value with the first focus that matches the predicate, if any.
    public func find(_ s: S, _ predicate: @escaping (A) -> Bool) -> Option<A> {
        return foldMap(s, { a in
            predicate(a) ? FirstOption(a) : FirstOption(Option.none())
        }).const.value
    }
    
    /// Modifies the focus with a function.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - f: Modifying function.
    /// - Returns: Modified source.
    public func modify(_ s: S, _ f: @escaping (A) -> B) -> T {
        return Id.fix(modifyF(s, { a in Id.pure(f(a)) })).value
    }
    
    /// Checks if any focus matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: True if any focus matches the predicate; false otherwise.
    public func exists(_ s: S, _ predicate: @escaping (A) -> Bool) -> Bool {
        return find(s, predicate).fold(constant(false), constant(true))
    }
    
    /// Checks if all foci match a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: True if all foci match the predicate; false otherwitse.
    public func forall(_ s: S, _ predicate: @escaping (A) -> Bool) -> Bool {
        return foldMap(s, predicate)
    }
    
    /// Extracts the focus viewed through the `PTraversal`.
    ///
    /// - Returns: A `State` of the source and target.
    public func extract() -> State<S, ArrayK<A>> {
        return State { s in (s, self.getAll(s)) }
    }
    
    /// Extracts the focus viewed through the `PTraversal`.
    ///
    /// - Returns: A `State` of the source and target.
    public func toState() -> State<S, ArrayK<A>> {
        return extract()
    }
    
    /// Extracts the focus viewed through the `PTraversal` and applies the provided function to it.
    ///
    /// - Returns: A `State` of the source and target, modified by the provided function.
    public func extractMap<C>(_ f: @escaping (A) -> C) -> State<S, ArrayK<C>> {
        return extract().map { x in x.map(f)^ }^
    }
}

public extension Traversal where S == T, A == B {
    /// Updates the focus viewed through the `Traversal` and returns its new value.
    ///
    /// - Parameter f: Updating function.
    /// - Returns: A `State` with the new value.
    func update(_ f: @escaping (A) -> A) -> State<S, ArrayK<A>> {
        return updateOld(f).map { x in x.map(f)^ }^
    }
    
    /// Updates the focus viewed through the `Traversal` and returns its old value.
    ///
    /// - Parameter f: Updating function.
    /// - Returns: A `State` with the old value.
    func updateOld(_ f: @escaping (A) -> A) -> State<S, ArrayK<A>> {
        return State { s in (self.modify(s, f), self.getAll(s)) }
    }
    
    /// Updates the focus viewed through the `Traversal`, ignoring the result.
    ///
    /// - Parameter f: Updating function.
    /// - Returns: A `State` ignoring the result.
    func update_(_ f: @escaping (A) -> A) -> State<S, ()> {
        return State { s in (self.modify(s, f), ()) }
    }
    
    /// Assigns the focus viewed through the `Traversal` and returns its new value.
    ///
    /// - Parameter a: Value to assign the focus.
    /// - Returns: A `State` with the new value.
    func assign(_ a: A) -> State<S, ArrayK<A>> {
        return update(constant(a))
    }
    
    /// Assigns the focus viewed through the `Traversal` and returns its old value.
    ///
    /// - Parameter a: Value to assign the focus.
    /// - Returns: A `State` with the old value.
    func assignOld(_ a: A) -> State<S, ArrayK<A>> {
        return updateOld(constant(a))
    }
    
    /// Assigns the focus viewed through the `Traversal`, ignoring the result.
    ///
    /// - Parameter a: Value to assign the focus.
    /// - Returns: A `State` ignoring the result.
    func assign_(_ a: A) -> State<S, ()> {
        return update_(constant(a))
    }
}

public extension Traversal where S == A, S == T, A == B {
    /// Provides an identity Traversal
    static var identity: Traversal<S, S> {
        return Iso<S, S>.identity.asTraversal
    }
    
    /// Provides a Traversal that takes an `S` or an `S` and strips the choice of `S`.
    static var codiagonal: Traversal<Either<S, S>, S> {
        return CodiagonalTraversal()
    }
}

extension PTraversal where A: Monoid {
    /// Folds all foci using their instance of `Monoid`.
    ///
    /// - Parameter s: Source.
    /// - Returns: Comination of all foci using their instance of `Monoid`.
    public func fold(_ s: S) -> A {
        return foldMap(s, id)
    }

    /// Folds all foci using their instance of `Monoid`.
    ///
    /// - Parameter s: Source.
    /// - Returns: Comination of all foci using their instance of `Monoid`.
    public func combineAll(_ s: S) -> A {
        return fold(s)
    }
}

private class ChoiceTraversal<S, T, U, V, A, B>: PTraversal<Either<S, U>, Either<T, V>, A, B> {
    private let first: PTraversal<S, T, A, B>
    private let second: PTraversal<U, V, A, B>
    
    init(first: PTraversal<S, T, A, B>, second: PTraversal<U, V, A, B>) {
        self.first = first
        self.second = second
    }

    override func modifyF<F: Applicative>(_ s: Either<S, U>, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, Either<T, V>> {
        return s.fold({ s in F.map(first.modifyF(s, f), { t in
            Either.left(t) }) },
                      { u in F.map(second.modifyF(u, f), { v in
                        Either.right(v) }) })
    }

}

private class TraversalFold<S, T, A, B>: Fold<S, A> {
    private let traversal: PTraversal<S, T, A, B>
    
    init(traversal: PTraversal<S, T, A, B>) {
        self.traversal = traversal
    }
    
    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        return traversal.foldMap(s, f)
    }
}

private class CodiagonalTraversal<S>: Traversal<Either<S, S>, S> {
    override func modifyF<F: Applicative>(_ s: Either<S, S>, _ f: @escaping (S) -> Kind<F, S>) -> Kind<F, Either<S, S>> {
        return s.bimap(f, f)
            .fold({ fa in F.map(fa, Either.left) },
                  { fa in F.map(fa, Either.right) })
    }
}

private class TraverseTraversal<T: Traverse, A, B>: PTraversal<Kind<T, A>, Kind<T, B>, A, B> {
    override func modifyF<F: Applicative>(_ s: Kind<T, A>, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, Kind<T, B>> {
        return T.traverse(s, f)
    }
}

private class Get2Traversal<S, T, A, B>: PTraversal<S, T, A, B> {
    private let get1: (S) -> A
    private let get2: (S) -> A
    private let set: (B, B, S) -> T
    
    init(get1: @escaping (S) -> A,
         get2: @escaping (S) -> A,
         set: @escaping (B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     { b1, b2 in self.set(b1, b2, s) })
    }
}

private class Get3Traversal<S, T, A, B>: PTraversal<S, T, A, B> {
    private let get1: (S) -> A
    private let get2: (S) -> A
    private let get3: (S) -> A
    private let set: (B, B, B, S) -> T
    
    init(get1: @escaping (S) -> A,
         get2: @escaping (S) -> A,
         get3: @escaping (S) -> A,
         set: @escaping (B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     { b1, b2, b3 in self.set(b1, b2, b3, s) })
    }
}

private class Get4Traversal<S, T, A, B>: PTraversal<S, T, A, B> {
    private let get1: (S) -> A
    private let get2: (S) -> A
    private let get3: (S) -> A
    private let get4: (S) -> A
    private let set: (B, B, B, B, S) -> T
    
    init(get1: @escaping (S) -> A,
         get2: @escaping (S) -> A,
         get3: @escaping (S) -> A,
         get4: @escaping (S) -> A,
         set: @escaping (B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     { b1, b2, b3, b4 in self.set(b1, b2, b3, b4, s) })
    }
}

private class Get5Traversal<S, T, A, B>: PTraversal<S, T, A, B> {
    private let get1: (S) -> A
    private let get2: (S) -> A
    private let get3: (S) -> A
    private let get4: (S) -> A
    private let get5: (S) -> A
    private let set: (B, B, B, B, B, S) -> T
    
    init(get1: @escaping (S) -> A,
         get2: @escaping (S) -> A,
         get3: @escaping (S) -> A,
         get4: @escaping (S) -> A,
         get5: @escaping (S) -> A,
         set: @escaping (B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     { b1, b2, b3, b4, b5 in self.set(b1, b2, b3, b4, b5, s) })
    }
}

private class Get6Traversal<S, T, A, B>: PTraversal<S, T, A, B> {
    private let get1: (S) -> A
    private let get2: (S) -> A
    private let get3: (S) -> A
    private let get4: (S) -> A
    private let get5: (S) -> A
    private let get6: (S) -> A
    private let set: (B, B, B, B, B, B, S) -> T
    
    init(get1: @escaping (S) -> A,
         get2: @escaping (S) -> A,
         get3: @escaping (S) -> A,
         get4: @escaping (S) -> A,
         get5: @escaping (S) -> A,
         get6: @escaping (S) -> A,
         set: @escaping (B, B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.get6 = get6
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     f(self.get6(s)),
                     { b1, b2, b3, b4, b5, b6 in self.set(b1, b2, b3, b4, b5, b6, s) })
    }
}

private class Get7Traversal<S, T, A, B> : PTraversal<S, T, A, B> {
    private let get1: (S) -> A
    private let get2: (S) -> A
    private let get3: (S) -> A
    private let get4: (S) -> A
    private let get5: (S) -> A
    private let get6: (S) -> A
    private let get7: (S) -> A
    private let set: (B, B, B, B, B, B, B, S) -> T
    
    init(get1: @escaping (S) -> A,
         get2: @escaping (S) -> A,
         get3: @escaping (S) -> A,
         get4: @escaping (S) -> A,
         get5: @escaping (S) -> A,
         get6: @escaping (S) -> A,
         get7: @escaping (S) -> A,
         set: @escaping (B, B, B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.get6 = get6
        self.get7 = get7
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     f(self.get6(s)),
                     f(self.get7(s)),
                     { b1, b2, b3, b4, b5, b6, b7 in self.set(b1, b2, b3, b4, b5, b6, b7, s) })
    }
}

private class Get8Traversal<S, T, A, B>: PTraversal<S, T, A, B> {
    private let get1: (S) -> A
    private let get2: (S) -> A
    private let get3: (S) -> A
    private let get4: (S) -> A
    private let get5: (S) -> A
    private let get6: (S) -> A
    private let get7: (S) -> A
    private let get8: (S) -> A
    private let set: (B, B, B, B, B, B, B, B, S) -> T
    
    init(get1: @escaping (S) -> A,
         get2: @escaping (S) -> A,
         get3: @escaping (S) -> A,
         get4: @escaping (S) -> A,
         get5: @escaping (S) -> A,
         get6: @escaping (S) -> A,
         get7: @escaping (S) -> A,
         get8: @escaping (S) -> A,
         set: @escaping (B, B, B, B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.get6 = get6
        self.get7 = get7
        self.get8 = get8
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     f(self.get6(s)),
                     f(self.get7(s)),
                     f(self.get8(s)),
                     { b1, b2, b3, b4, b5, b6, b7, b8 in self.set(b1, b2, b3, b4, b5, b6, b7, b8, s) })
    }
}

private class Get9Traversal<S, T, A, B>: PTraversal<S, T, A, B> {
    private let get1: (S) -> A
    private let get2: (S) -> A
    private let get3: (S) -> A
    private let get4: (S) -> A
    private let get5: (S) -> A
    private let get6: (S) -> A
    private let get7: (S) -> A
    private let get8: (S) -> A
    private let get9: (S) -> A
    private let set: (B, B, B, B, B, B, B, B, B, S) -> T
    
    init(get1: @escaping (S) -> A,
         get2: @escaping (S) -> A,
         get3: @escaping (S) -> A,
         get4: @escaping (S) -> A,
         get5: @escaping (S) -> A,
         get6: @escaping (S) -> A,
         get7: @escaping (S) -> A,
         get8: @escaping (S) -> A,
         get9: @escaping (S) -> A,
         set: @escaping (B, B, B, B, B, B, B, B, B, S) -> T) {
        self.get1 = get1
        self.get2 = get2
        self.get3 = get3
        self.get4 = get4
        self.get5 = get5
        self.get6 = get6
        self.get7 = get7
        self.get8 = get8
        self.get9 = get9
        self.set = set
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (A) -> Kind<F, B>) -> Kind<F, T> {
        return F.map(f(self.get1(s)),
                     f(self.get2(s)),
                     f(self.get3(s)),
                     f(self.get4(s)),
                     f(self.get5(s)),
                     f(self.get6(s)),
                     f(self.get7(s)),
                     f(self.get8(s)),
                     f(self.get9(s)),
                     { b1, b2, b3, b4, b5, b6, b7, b8, b9 in self.set(b1, b2, b3, b4, b5, b6, b7, b8, b9, s) })
    }
}

private class ComposeTraversal<S, T, A, B, C, D>: PTraversal<S, T, C, D> {
    private let first: PTraversal<S, T, A, B>
    private let second: PTraversal<A, B, C, D>
    
    init(first: PTraversal<S, T, A, B>, second: PTraversal<A, B, C, D>) {
        self.first = first
        self.second = second
    }
    
    override func modifyF<F: Applicative>(_ s: S, _ f: @escaping (C) -> Kind<F, D>) -> Kind<F, T> {
        return self.first.modifyF(s, { a in
            self.second.modifyF(a, f)
        })
    }
}

extension Traversal {
    internal var fix: Traversal<S, A> {
        return self as! Traversal<S, A>
    }
}
