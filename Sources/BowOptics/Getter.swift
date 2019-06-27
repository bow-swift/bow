import Foundation
import Bow

/// Witness for the `Getter<S, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForGetter {}

/// Partial application of the Getter type constructor, omitting the last parameter.
public final class GetterPartial<S>: Kind<ForGetter, S> {}

/// Higher Kinded Type alias to improve readability over `Kind2<ForGetter, S, A>`
public typealias GetterOf<S, A> = Kind<GetterPartial<S>, A>

/// A `Getter` is an optic that allows to see into a structure and getting a focus.
///
/// It can be seen as a function `(S) -> A` meaning that we can look into an `S` and get an `A`.
///
/// Parameters:
///     - `S`: source of the `Getter`.
///     - `A`: focus of the `Getter`.
public class Getter<S, A>: GetterOf<S, A> {
    private let getFunc: (S) -> A
    
    /// Composes a `Getter` with another `Getter`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Getter` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Getter<S, A>, rhs: Getter<A, C>) -> Getter<S, C> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `Getter` with a `Lens`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Getter` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Getter<S, A>, rhs: Lens<A, C>) -> Getter<S, C> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `Getter` with an `Iso`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Getter` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Getter<S, A>, rhs: Iso<A, C>) -> Getter<S, C> {
        return lhs.compose(rhs)
    }
    
    /// Composes a `Getter` with a `Fold`.
    ///
    /// - Parameters:
    ///   - lhs: Left side of the composition.
    ///   - rhs: Right side of the composition.
    /// - Returns: A `Fold` resulting from the sequential application of the two provided optics.
    public static func +<C>(lhs: Getter<S, A>, rhs: Fold<A, C>) -> Fold<S, C> {
        return lhs.compose(rhs)
    }
    
    /// Initializes a Getter.
    ///
    /// - Parameter get: Function to focus into a structure.
    public init(get: @escaping (S) -> A) {
        self.getFunc = get
    }
    
    /// Obtains the focus for a given source.
    ///
    /// - Parameter s: Source.
    /// - Returns: Focus.
    public func get(_ s: S) -> A {
        return getFunc(s)
    }
    
    /// Joins two Getters with the same focus.
    ///
    /// - Parameter other: `Getter` to join with.
    /// - Returns: A `Getter` that operates on either of the sources and extracts their focus.
    public func choice<C>(_ other: Getter<C, A>) -> Getter<Either<S, C>, A> {
        return Getter<Either<S, C>, A>(get: { either in
            either.fold(self.get, other.get)
        })
    }
    
    /// Pairs two disjoint Getters.
    ///
    /// - Parameter other: `Getter` to pair with.
    /// - Returns: A `Getter` that operates in both sources at the same time, extracting both foci.
    public func split<C, D>(_ other: Getter<C, D>) -> Getter<(S, C), (A, D)> {
        return Getter<(S, C), (A, D)>(get: { (s, c) in (self.get(s), other.get(c)) })
    }
    
    /// Zips two Getters with the same source.
    ///
    /// - Parameter other: `Getter` to zip with.
    /// - Returns: A `Getter` that extracts both foci for a given source.
    public func zip<C>(_ other: Getter<S, C>) -> Getter<S, (A, C)> {
        return Getter<S, (A, C)>(get: { s in (self.get(s), other.get(s)) })
    }
    
    /// Pairs this `Getter` with another type, placing this as the first element.
    ///
    /// - Returns: A `Getter` that operates on tuples where the second argument remains unchanged.
    public func first<C>() -> Getter<(S, C), (A, C)> {
        return Getter<(S, C), (A, C)>(get: { (s, c) in (self.get(s), c) })
    }
    
    /// Pairs this `Getter` with another type, placing this as the second element.
    ///
    /// - Returns: A `Getter` that operates on tuples where the first argument remains unchanged.
    public func second<C>() -> Getter<(C, S), (C, A)> {
        return Getter<(C, S), (C, A)>(get: { (c, s) in (c, self.get(s)) })
    }
    
    /// Creates the sum of this `Getter` with another type, placing this as the left side.
    ///
    /// - Returns: A `Getter` that operates on `Either`s where the right side remains unchanged.
    public func left<C>() -> Getter<Either<S, C>, Either<A, C>> {
        return Getter<Either<S, C>, Either<A, C>>(get: { either in
            either.bimap(self.get, id)
        })
    }
    
    /// Creates the sum of this `Getter` with another type, placing this as the right side.
    ///
    /// - Returns: A `Getter` that operates on `Either`s where the left side remains unchanged.
    public func right<C>() -> Getter<Either<C, S>, Either<C, A>> {
        return Getter<Either<C, S>, Either<C, A>>(get: { either in
            Either.fix(either.map(self.get))
        })
    }
    
    /// Composes this `Getter` with a `Getter`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Getter` resulting from the sequential application of both optics.
    public func compose<C>(_ other: Getter<A, C>) -> Getter<S, C> {
        return Getter<S, C>(get: other.get <<< self.get)
    }
    
    /// Composes this `Getter` with a `Lens`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Getter` resulting from the sequential application of both optics.
    public func compose<C>(_ other: Lens<A, C>) -> Getter<S, C> {
        return Getter<S, C>(get: other.get <<< self.get)
    }
    
    /// Composes this `Getter` with an `Iso`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Getter` resulting from the sequential application of both optics.
    public func compose<C>(_ other: Iso<A, C>) -> Getter<S, C> {
        return Getter<S, C>(get: other.get <<< self.get)
    }
    
    /// Composes this `Getter` with a `Fold`.
    ///
    /// - Parameter other: Value to compose with.
    /// - Returns: A `Fold` resulting from the sequential application of both optics.
    public func compose<C>(_ other: Fold<A, C>) -> Fold<S, C> {
        return self.asFold.compose(other)
    }
    
    /// Converts this `Getter` into a `Fold`.
    public var asFold: Fold<S, A> {
        return GetterFold(getter: self)
    }
    
    /// Obtains the focus if it matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: An optional value that is present if the focus matches the predicate, or empty otherwise.
    public func find(_ s: S, _ predicate: (A) -> Bool) -> Option<A> {
        let a = get(s)
        if predicate(a) {
            return Option.some(a)
        } else {
            return Option.none()
        }
    }
    
    /// Checks if the focus matches a predicate.
    ///
    /// - Parameters:
    ///   - s: Source.
    ///   - predicate: Testing predicate.
    /// - Returns: A boolean value indicating if the focus matches the predicate.
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
    public func asks<B>(_ f: @escaping (A) -> B) -> Reader<S, B> {
        return ask().map(f)^
    }
    
    /// Extracts the focus view through the `Getter`.
    ///
    /// - Returns: A `State` of the source and target.
    public func extract() -> State<S, A> {
        return State({ s in (s, self.get(s)) })
    }
    
    /// Extracts the focus view through the `Getter`.
    ///
    /// - Returns: A `State` of the source and target.
    public func toState() -> State<S, A> {
        return extract()
    }
    
    /// Extracts the focus view through the `Getter` and applies the provided function to it.
    ///
    /// - Returns: A `State` of the source and target, modified by the provided function.
    public func extractMap<B>(_ f: @escaping (A) -> B) -> State<S, B> {
        return extract().map(f)^
    }
}

public extension Getter where S == A {
    /// Provides an identity `Getter`.
    static var identity: Getter<S, S> {
        return Iso<S, S>.identity.asGetter
    }
    
    /// Provides a `Getter` that takes either `S` or `S` and strips the choice of `S`.
    static var codiagonal: Getter<Either<S, S>, S> {
        return Getter<Either<S, S>, S>(get: { either in
            either.fold(id, id)
        })
    }
}

private class GetterFold<S, A> : Fold<S, A> {
    private let getter : Getter<S, A>
    
    init(getter : Getter<S, A>) {
        self.getter = getter
    }
    
    override func foldMap<R: Monoid>(_ s: S, _ f: @escaping (A) -> R) -> R {
        return f(getter.get(s))
    }
}
