import Foundation

/// Witness for the `Either<A, B>` data type. To be used in simulated Higher Kinded Types.
public final class ForEither {}

/// Partial application of the Either type constructor, omitting the last parameter.
public final class EitherPartial<L>: Kind<ForEither, L> {}

/// Higher Kinded Type alias to improve readability over `Kind2<ForEither, A, B>`
public typealias EitherOf<A, B> = Kind<EitherPartial<A>, B>

/// Sum type of types `A` and `B`. Represents a value of either one of those types, but not both at the same time. Values of type `A` are called `left`; values of type `B` are called right.
public final class Either<A, B>: EitherOf<A, B> {
    private let value: _Either<A, B>
    
    private init(_ value: _Either<A, B>) {
        self.value = value
    }
    
    /// Constructs a left value.
    ///
    /// - Parameter a: Value to be wrapped in a left of this Either type.
    /// - Returns: A left value of Either.
    public static func left(_ a: A) -> Either<A, B> {
        return Either(.left(a))
    }

    /// Constructs a right value
    ///
    /// - Parameter b: Value to be wrapped in a right of this Either type.
    /// - Returns: A right value of Either.
    public static func right(_ b: B) -> Either<A, B> {
        return Either(.right(b))
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Either.
    public static func fix(_ fa: EitherOf<A, B>) -> Either<A, B> {
        return fa as! Either<A, B>
    }

    /// Applies the provided closures based on the content of this `Either` value.
    ///
    /// - Parameters:
    ///   - fa: Closure to apply if the contained value in this `Either` is a member of the left type.
    ///   - fb: Closure to apply if the contained value in this `Either` is a member of the right type.
    /// - Returns: Result of applying the corresponding closure to this value.
    public func fold<C>(_ fa: (A) -> C, _ fb: (B) -> C) -> C {
        switch value {
            case let .left(a): return fa(a)
            case let .right(b): return fb(b)
        }
    }

    /// Checks if this value belongs to the left type.
    public var isLeft: Bool {
        return fold(constant(true), constant(false))
    }

    /// Checks if this value belongs to the right type.
    public var isRight: Bool {
        return !isLeft
    }

    /// Attempts to obtain a value of the left type.
    ///
    /// This propery is unsafe and can cause fatal errors if it is invoked on a right value.
    public var leftValue: A {
        return fold(id, { _ in fatalError("Attempted to obtain leftValue on a right instance") })
    }
    
    /// Attempts to obtain a value of the right type.
    ///
    /// This property is unsafe and can cause fatal errors if it is invoked on a left value.
    public var rightValue: B {
        return fold({ _ in fatalError("Attempted to obtain rightValue on a left instance") }, id)
    }

    /// Returns the value of the right type, or `nil` if it is a left value.
    public var orNil: B? {
        return fold(constant(nil), id)
    }

    /// Reverses the types of this either. Left values become right values and vice versa.
    ///
    /// - Returns: An either value with its types reversed respect to this one.
    public func swap() -> Either<B, A> {
        return fold(Either<B, A>.right, Either<B, A>.left)
    }

    /// Transforms both type parameters, preserving the structure of this value.
    ///
    /// - Parameters:
    ///   - fa: Closure to be applied when there is a left value.
    ///   - fb: Closure to be applied when there is a right value.
    /// - Returns: Result of applying the corresponding closure to this value.
    public func bimap<C, D>(_ fa: (A) -> C, _ fb: (B) -> D) -> Either<C, D> {
        return fold({ a in Either<C, D>.left(fa(a)) },
                    { b in Either<C, D>.right(fb(b)) })
    }

    /// Transforms the left type parameter, preserving the structure of this value.
    ///
    /// - Parameter f: Transforming closure.
    /// - Returns: Result of appliying the transformation to any left value in this value.
    public func mapLeft<C>(_ f: (A) -> C) -> Either<C, B> {
        return bimap(f, id)
    }

    /// Returns the value from this `Either.right` value or allows callers to transform the `Either.left` to `Either.right`.
    ///
    /// - Parameter f: Left transforming function.
    /// - Returns: Value of this `Either.right` or transformation of this `Either.left`.
    public func getOrHandle(_ f: (A) -> B) -> B {
        return fold(f, id)
    }

    /// Converts this `Either` to an `Option`.
    ///
    /// This conversion is lossy. Left values are mapped to `Option.none()` and right values to `Option.some()`. The original `Either cannot be reconstructed from the output of this conversion.
    ///
    /// - Returns: An option containing a right value, or none if there is a left value.
    public func toOption() -> Option<B> {
        return fold(constant(Option<B>.none()), Option<B>.some)
    }

    /// Obtains the value wrapped if it is a right value, or the default value provided as an argument.
    ///
    /// - Parameter defaultValue: Value to be returned if this value is left.
    /// - Returns: The wrapped value if it is right; otherwise, the default value.
    public func getOrElse(_ defaultValue: B) -> B {
        return fold(constant(defaultValue), id)
    }

    /// Filters the right values, providing a default left value if the do not match the provided predicate.
    ///
    /// - Parameters:
    ///   - predicate: Predicate to test the right value.
    ///   - defaultValue: Value to be returned if the right value does not satisfies the predicate.
    /// - Returns: This value, if it matches the predicate or is left; otherwise, a left value wrapping the default value.
    public func filterOrElse(_ predicate : @escaping (B) -> Bool, _ defaultValue : A) -> Either<A, B> {
        return fold(Either<A, B>.left,
                    { b in predicate(b) ?
                        Either<A, B>.right(b) :
                        Either<A, B>.left(defaultValue) })
    }

    /// Filters the right values, providing a function to transform those that do not match the predicate into a left-type value.
    ///
    /// - Parameters:
    ///   - predicate: Filtering predicate.
    ///   - f: Transforming function.
    /// - Returns: This value, if it matches the predicate or is left; otherwise, a left value wrapping the transformation of the right value.
    public func filterOrOther(_ predicate: @escaping (B) -> Bool, _ f: @escaping (B) -> A) -> Either<A, B> {
        return flatMap { b in predicate(b) ? Either.right(b) : Either.left(f(b)) }^
    }

    /// Flattens the right side of this value, providing a default value in case the wrapped value is not present.
    ///
    /// - Parameter f: Function providing a default value.
    /// - Returns: An Either value where the right side is not optional.
    public func leftIfNull<BB>(_ f: @escaping @autoclosure () -> A) -> Either<A, BB> where B == Optional<BB> {
        return flatMap { b in
            if let some = b {
                return Either<A, BB>.right(some)
            } else {
                return Either<A, BB>.left(f())
            }
        }^
    }
}

// MARK: Functions when the right side is Equatable
public extension Either where B: Equatable {
    /// Checks if this value has an element in the right side.
    ///
    /// - Parameter element: Element to check.
    /// - Returns: Boolean value indicating if the element was found or not.
    func contains(_ element: B) -> Bool {
        return fold(constant(false), { b in b == element })
    }
}

public extension Either where A == B {
    /// Returns a value from either side.
    func merge() -> A {
        fold(id, id)
    }
}

// MARK: Either from Optional
public extension Optional {
    /// Converts this optional to an `Either.right` value, providing a default value if it is nil.
    ///
    /// - Parameter f: Default value provider.
    /// - Returns: A right value containing the wrapped value, or a left with the provided default value.
    func rightIfNotNull<A>(_ f: @autoclosure () -> A) -> Either<A, Wrapped> {
        if let value = self {
            return .right(value)
        } else {
            return .left(f())
        }
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in the higher-kind form.
/// - Returns: Value cast to Either.
public postfix func ^<A, B>(_ fa: EitherOf<A, B>) -> Either<A, B> {
    return Either.fix(fa)
}

private enum _Either<A, B> {
    case left(A)
    case right(B)
}

// MARK: Conformance of `Either` to `CustomStringConvertible`
extension Either: CustomStringConvertible {
    public var description: String {
        return fold({ a in "Left(\(a))"},
                    { b in "Right(\(b))"})
    }
}

// MARK: Conformance of `Either` to `CustomDebugStringConvertible`, provided that both of its type arguments conform to `CustomDebugStringConvertible`.
extension Either: CustomDebugStringConvertible where A: CustomDebugStringConvertible, B: CustomDebugStringConvertible {
    public var debugDescription: String {
        return fold({ a in "Left(\(a.debugDescription)"},
                    { b in "Right(\(b.debugDescription))"})
    }
}

// MARK: Instance of `EquatableK` for `Either`.
extension EitherPartial: EquatableK where L: Equatable {
    public static func eq<A>(_ lhs: Kind<EitherPartial<L>, A>, _ rhs: Kind<EitherPartial<L>, A>) -> Bool where A : Equatable {
        let el = Either.fix(lhs)
        let er = Either.fix(rhs)
        return el.fold({ la in er.fold({ lb in la == lb }, constant(false)) },
                       { ra in er.fold(constant(false), { rb in ra == rb })})
    }
}

// MARK: Instance of `Functor` for `Either`.
extension EitherPartial: Functor {
    public static func map<A, B>(_ fa: Kind<EitherPartial<L>, A>, _ f: @escaping (A) -> B) -> Kind<EitherPartial<L>, B> {
        return Either.fix(fa).fold(Either.left, Either.right <<< f)
    }
}

// MARK: Instance of `Applicative` for `Either`.
extension EitherPartial: Applicative {
    public static func pure<A>(_ a: A) -> Kind<EitherPartial<L>, A> {
        return Either.right(a)
    }
}

// MARK: Instance of `Selective` for `Either`
extension EitherPartial: Selective {}

// MARK: Instance of `Monad` for `Either`.
extension EitherPartial: Monad {
    public static func flatMap<A, B>(_ fa: Kind<EitherPartial<L>, A>, _ f: @escaping (A) -> Kind<EitherPartial<L>, B>) -> Kind<EitherPartial<L>, B> {
        return Either.fix(fa).fold(Either.left, f)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<EitherPartial<L>, Either<A, B>>) -> Kind<EitherPartial<L>, B> {
        return Either.fix(f(a)).fold(Either<L, B>.left,
                  { either in
                    either.fold({ left in tailRecM(left, f)},
                                Either<L, B>.right)
        })
    }
}

// MARK: Instance of `ApplicativeError` for `Either`.
extension EitherPartial: ApplicativeError {
    public typealias E = L

    public static func raiseError<A>(_ e: L) -> Kind<EitherPartial<L>, A> {
        return Either.left(e)
    }

    public static func handleErrorWith<A>(_ fa: Kind<EitherPartial<L>, A>, _ f: @escaping (L) -> Kind<EitherPartial<L>, A>) -> Kind<EitherPartial<L>, A> {
        return Either.fix(fa).fold(f, constant(Either.fix(fa)))
    }
}

// MARK: Instance of `MonadError` for `Either`.
extension EitherPartial: MonadError {}

// MARK: Instance of `Foldable` for `Either`.
extension EitherPartial: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<EitherPartial<L>, A>, _ c: B, _ f: @escaping (B, A) -> B) -> B {
        return Either.fix(fa).fold(constant(c), { b in f(c, b) })
    }

    public static func foldRight<A, B>(_ fa: Kind<EitherPartial<L>, A>, _ c: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Either.fix(fa).fold(constant(c), { b in f(b, c) })
    }
}

// MARK: Instance of `Traverse` for `Either`.
extension EitherPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<EitherPartial<L>, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<EitherPartial<L>, B>> {
        return Either.fix(fa).fold({ a in G.pure(Either.left(a)) },
                                   { b in G.map(f(b), { c in Either.right(c) }) })
    }
}

// MARK: Instance of `SemigroupK` for `Either`.
extension EitherPartial: SemigroupK {
    public static func combineK<A>(_ x: Kind<EitherPartial<L>, A>, _ y: Kind<EitherPartial<L>, A>) -> Kind<EitherPartial<L>, A> {
        return Either.fix(x).fold(constant(Either.fix(y)), Either.right)
    }
}

// MARK: Instance of `Semigroup` for `Either`.
extension Either: Semigroup where A: Semigroup, B: Semigroup {
    public func combine(_ other: Either<A, B>) -> Either<A, B> {
        return self.fold({ l1 in other.fold({ l2 in .left(l1.combine(l2)) }, { r2 in .left(l1) }) },
                         { r1 in other.fold({ l2 in .left(l2) }, { r2 in .right(r1.combine(r2)) }) })
    }
}

// MARK: Instance of `Monoid` for `Either`.
extension Either: Monoid where A: Monoid, B: Monoid {
    public static func empty() -> Either<A, B> {
        return .right(B.empty())
    }
}
