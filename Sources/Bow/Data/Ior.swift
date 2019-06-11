import Foundation

/// Witness for the `Ior<A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForIor {}

/// Partial application of the Ior type constructor, omitting the last parameter.
public final class IorPartial<L>: Kind<ForIor, L> {}

/// Higher Kinded Type alias to improve readability over `Kind<IorPartial<A>, B>`.
public typealias IorOf<A, B> = Kind<IorPartial<A>, B>

/// Ior represents an inclusive-or of two different types. It may have a value of the left type, the right type or both at the same time.
public final class Ior<A, B>: IorOf<A, B> {
    private let value: _Ior<A, B>
    
    private init(_ value: _Ior<A, B>) {
        self.value = value
    }
    
    /// Creates an Ior value of the left type.
    ///
    /// - Parameter a: A value of the left type.
    /// - Returns: An `Ior` of the left type.
    public static func left(_ a: A) -> Ior<A, B> {
        return Ior<A, B>(.left(a))
    }
    
    /// Creates an Ior value of the right type.
    ///
    /// - Parameter b: A value of the right type.
    /// - Returns: An `Ior` of the right type.
    public static func right(_ b: B) -> Ior<A, B> {
        return Ior<A, B>(.right(b))
    }
    
    /// Creates an Ior value with both types.
    ///
    /// - Parameters:
    ///   - a: A value of the left type.
    ///   - b: A value of the right type.
    /// - Returns: An `Ior` of both types.
    public static func both(_ a: A, _ b: B) -> Ior<A, B> {
        return Ior<A, B>(.both(a, b))
    }
    
    /// Creates an Ior value from two optional values.
    ///
    /// - Parameters:
    ///   - ma: An optional value of the left type.
    ///   - mb: An optional value of the right type.
    /// - Returns: An optional `Ior` that is empty if both options are empty, or has a present `Ior` with the present values of the options.
    public static func fromOptions(_ ma: Option<A>, _ mb: Option<B>) -> Option<Ior<A, B>> {
        return ma.fold({ mb.fold({ Option.none() },
                                 { b in Option.some(Ior.right(b))}) },
                       { a in mb.fold({ Option.some(Ior.left(a)) },
                                      { b in Option.some(Ior.both(a, b))})})
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Ior.
    public static func fix(_ fa: IorOf<A, B>) -> Ior<A, B> {
        return fa as! Ior<A, B>
    }
    
    /// Applies the provided closures based on the content of this `Ior` value.
    ///
    /// - Parameters:
    ///   - fa: Closure to apply if the contained value in this `Ior` is a member of the left type.
    ///   - fb: Closure to apply if the contained value in this `Ior` is a member of the right type.
    ///   - fab: Closure to apply if the contained values in this `Ior` are members of both types.
    /// - Returns: Result of aplying the corresponding closure to this value.
    public func fold<C>(_ fa: (A) -> C, _ fb: (B) -> C, _ fab: (A, B) -> C) -> C {
        switch value {
        case let .left(a): return fa(a)
        case let .right(b): return fb(b)
        case let .both(a, b): return fab(a, b)
        }
    }
    
    /// Checks if this value contains only a value of the left type.
    public var isLeft: Bool {
        return fold(constant(true), constant(false), constant(false))
    }
    
    /// Checks if this value contains only a value of the right type.
    public var isRight: Bool {
        return fold(constant(false), constant(true), constant(false))
    }
    
    /// Checks if this value contains values of both left and right types.
    public var isBoth: Bool {
        return fold(constant(false), constant(false), constant(true))
    }

    /// Transforms both type parameters with the provided closures.
    ///
    /// - Parameters:
    ///   - fa: Closure to transform the left type.
    ///   - fb: Closure to transform the right type.
    /// - Returns: An `Ior` value with its type parameters transformed using the provided functions.
    public func bimap<C, D>(_ fa: (A) -> C, _ fb: (B) -> D) -> Ior<C, D> {
        return fold({ a in Ior<C, D>.left(fa(a)) },
                    { b in Ior<C, D>.right(fb(b)) },
                    { a, b in Ior<C, D>.both(fa(a), fb(b)) })
    }
    
    /// Transforms the left type parameter with the provided closure.
    ///
    /// - Parameter f: Transforming function.
    /// - Returns: An `Ior` value with its left type parameter transformed using the provided function.
    public func mapLeft<C>(_ f: (A) -> C) -> Ior<C, B> {
        return fold({ a in Ior<C, B>.left(f(a)) },
                    Ior<C, B>.right,
                    { a, b in Ior<C, B>.both(f(a), b) })
    }
    
    /// Swaps the type parameters.
    ///
    /// - Returns: An `Ior` where the left values are right and vice versa, and both values are swapped.
    public func swap() -> Ior<B, A> {
        return fold(Ior<B, A>.right,
                    Ior<B, A>.left,
                    { a, b in Ior<B, A>.both(b, a) })
    }
    
    /// Transforms this `Ior` to nested `Either` values representing the possible values wrapped.
    ///
    /// - Returns: A value where:
    ///     - `Ior.left` is mapped to `Either.left(Either.left)`.
    ///     - `Ior.right` is mapped to `Either.left(Either.right)`.
    ///     - `Ior.both` is mapped to `Either.right` containing a tuple of the two values.
    public func unwrap() -> Either<Either<A, B>, (A, B)> {
        return fold({ a in Either.left(Either.left(a)) },
                    { b in Either.left(Either.right(b)) },
                    { a, b in Either.right((a, b)) })
    }
    
    /// Obtains a tuple of optional values with the values wrapped in this `Ior`.
    ///
    /// - Returns: A tuple of optional values that are present or absent based on the contents of this `Ior`.
    public func pad() -> (Option<A>, Option<B>) {
        return fold({ a in (Option.some(a), Option.none()) },
                    { b in (Option.none(), Option.some(b)) },
                    { a, b in (Option.some(a), Option.some(b)) })
    }
    
    /// Converts this `Ior` to an `Either`.
    ///
    /// - Returns: An `Either` value with a direct mapping of the left and right cases, and mapping the both case to a right value (losing the left value).
    public func toEither() -> Either<A, B> {
        return fold(Either.left,
                    Either.right,
                    { _, b in Either.right(b) })
    }
    
    /// Converts this `Ior` to an `Option`.
    ///
    /// - Returns: An `Option` of the right type, discarding any left value in this `Ior`.
    public func toOption() -> Option<B> {
        return fold({ _ in Option<B>.none() },
                    { b in Option<B>.some(b) },
                    { _, b in Option<B>.some(b) })
    }
    
    /// Obtains a value of the right type, or a default if there is none.
    ///
    /// - Parameter defaultValue: Default value for the left case.
    /// - Returns: Right value wrapped in the right and both cases, or the default value if this `Ior` contains a left value.
    public func getOrElse(_ defaultValue: B) -> B {
        return fold(constant(defaultValue),
                    id,
                    { _, b in b })
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Ior.
public postfix func ^<A, B>(_ fa: IorOf<A, B>) -> Ior<A, B> {
    return Ior.fix(fa)
}

private enum _Ior<A, B> {
    case left(A)
    case right(B)
    case both(A, B)
}

// MARK: Conformance to `CustomStringConvertible`
extension Ior: CustomStringConvertible {
    public var description: String {
        return fold({ a in "Left(\(a))" },
                    { b in "Right(\(b))" },
                    { a, b in "Both(\(a),\(b))" })
    }
}

// MARK: Conformance to `CustomDebugStringConvertible`
extension Ior: CustomDebugStringConvertible where A: CustomDebugStringConvertible, B: CustomDebugStringConvertible {
    public var debugDescription : String {
        return fold({ a in "Left(\(a.debugDescription))" },
                    { b in "Right(\(b.debugDescription))" },
                    { a, b in "Both(\(a.debugDescription), \(b.debugDescription))" })
    }
}

// MARK: Instance of `EquatableK` for `Ior`
extension IorPartial: EquatableK where L: Equatable {
    public static func eq<A>(_ lhs: Kind<IorPartial<L>, A>, _ rhs: Kind<IorPartial<L>, A>) -> Bool where A : Equatable {
        let il = Ior.fix(lhs)
        let ir = Ior.fix(rhs)
        return il.fold({ la in ir.fold({ ra in la == ra }, constant(false), constant(false)) },
                       { lb in ir.fold(constant(false), { rb in lb == rb }, constant(false)) },
                       { la, lb in ir.fold(constant(false), constant(false), { ra, rb in la == ra && lb == rb })})
    }
}

// MARK: Instance of `Functor` for `Ior`
extension IorPartial: Functor {
    public static func map<A, B>(_ fa: Kind<IorPartial<L>, A>, _ f: @escaping (A) -> B) -> Kind<IorPartial<L>, B> {
        let ior = Ior.fix(fa)
        return ior.fold({ a    in Ior.left(a) },
                        { b    in Ior.right(f(b)) },
                        { a, b in Ior.both(a, f(b)) })
    }
}

// MARK: Instance of `Applicative` for `Ior`
extension IorPartial: Applicative where L: Semigroup {
    public static func pure<A>(_ a: A) -> Kind<IorPartial<L>, A> {
        return Ior.right(a)
    }
}

// MARK: Instance of `Selective` for `Ior`
extension IorPartial: Selective where L: Semigroup {}

// MARK: Instance of `Monad` for `Ior`
extension IorPartial: Monad where L: Semigroup {
    public static func flatMap<A, B>(_ fa: Kind<IorPartial<L>, A>, _ f: @escaping (A) -> Kind<IorPartial<L>, B>) -> Kind<IorPartial<L>, B> {
        return Ior.fix(fa).fold(
            Ior.left,
            f,
            { a, b in Ior.fix(f(b)).fold({ lft in Ior.left(a.combine(lft)) },
                                         { rgt in Ior.right(rgt) },
                                         { lft, rgt in Ior.both(a.combine(lft), rgt) })
        })
    }

    private static func loop<A, B>(_ v : Ior<L, Either<A, B>>,
                                      _ f : @escaping (A) -> Ior<L, Either<A, B>>) -> Ior<L, B> {
            return v.fold({ left in .left(left) },
                          { right in
                            right.fold({ a in loop(f(a), f) },
                                       { b in .right(b) })
            },
                          { left, right in
                            right.fold({ a in
                                f(a).fold({ aLeft in .left(aLeft.combine(left)) },
                                          { aRight in loop(.both(left, aRight), f) },
                                          { aLeft, aRight in loop(.both(left.combine(aLeft), aRight), f) })
                                        },
                                       { b in .both(left, b) })
            })
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<IorPartial<L>, Either<A, B>>) -> Kind<IorPartial<L>, B> {
        return loop(Ior.fix(f(a)), { a in Ior.fix(f(a)) })
    }
}

// MARK: Instance of `Foldable` for `Ior`
extension IorPartial: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<IorPartial<L>, A>, _ c: B, _ f: @escaping (B, A) -> B) -> B {
        let ior = Ior.fix(fa)
        return ior.fold(constant(c),
                        { b    in f(c, b) },
                        { _, b in f(c, b) })
    }

    public static func foldRight<A, B>(_ fa: Kind<IorPartial<L>, A>, _ c: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        let ior = Ior.fix(fa)
        return ior.fold(constant(c),
                        { b    in f(b, c) },
                        { _, b in f(b, c) })
    }
}

// MARK: Instance of `Traverse` for `Ior`
extension IorPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<IorPartial<L>, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<IorPartial<L>, B>> {
        let ior = Ior.fix(fa)
        return ior.fold({ a    in G.pure(Ior.left(a)) },
                        { b    in f(b).map(Ior.right) },
                        { _, b in f(b).map(Ior.right) })
    }
}
