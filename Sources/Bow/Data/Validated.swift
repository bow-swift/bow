import Foundation

/// Witness for the `Validated<E, A>` data type. To be used in simulated Higher Kinded Types.
public final class ForValidated {}

/// Partial application of the Validated type constructor, ommitting the last parameter.
public final class ValidatedPartial<I>: Kind<ForValidated, I> {}

/// Higher Kinded Type alias to improve readability over `Kind<ValidatedPartial<E>, A>`.
public typealias ValidatedOf<E, A> = Kind<ValidatedPartial<E>, A>

/// Alias for a `Validated` where the invalid case is a `NonEmptyArray`.
public typealias ValidatedNEA<E, A> = Validated<NEA<E>, A>

/// Validated is a data type to represent valid and invalid values. It is similar to `Either`, but with error accumulation in the invalid case.
public final class Validated<E, A>: ValidatedOf<E, A> {
    private let value: _Validated<E, A>
    
    private init(_ value: _Validated<E, A>) {
        self.value = value
    }
    
    /// Constructs a valid value.
    ///
    /// - Parameter value: Valid value to be wrapped in this validated.
    /// - Returns: A `Validated` value wrapping the parameter.
    public static func valid(_ value: A) -> Validated<E, A> {
        return Validated<E, A>(.valid(value))
    }
    
    /// Constructs an invalid value.
    ///
    /// - Parameter value: Invalid value to be wrapped in this validated.
    /// - Returns: A `Validated` value wrapping the parameter.
    public static func invalid(_ value: E) -> Validated<E, A> {
        return Validated<E, A>(.invalid(value))
    }
    
    /// Constructs a `Validated` from a `Try` value.
    ///
    /// - Parameter t: A `Try` value.
    /// - Returns: A `Validated` that contains an invalid error or a valid value, obtained from the `Try` value.
    public static func fromTry(_ t: Try<A>) -> Validated<Error, A> {
        return t.fold(Validated<Error, A>.invalid, Validated<Error, A>.valid)
    }
    
    /// Constructs a `Validated` from an `Option` value.
    ///
    /// - Parameters:
    ///   - m: An `Option` value.
    ///   - ifNone: A closure providing a value for the invalid case if the option is not present.
    /// - Returns: A `Validated` containing a valid value from the option, or an invalid wrapping the default value from the closure.
    public static func fromOption(_ m: Option<A>, ifNone: @escaping () -> E) -> Validated<E, A> {
        return m.fold(ifNone >>> Validated<E, A>.invalid, Validated<E, A>.valid)
    }
    
    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Validated.
    public static func fix(_ fa: ValidatedOf<E, A>) -> Validated<E, A> {
        return fa as! Validated<E, A>
    }
    
    /// Applies the provided closures based on the content of this `Validated` value.
    ///
    /// - Parameters:
    ///   - fe: Closure to apply if the contained value is invalid.
    ///   - fa: Closure to apply if the contained value is valid.
    /// - Returns: Result of applying the corresponding closure to the contained value.
    public func fold<C>(_ fe: (E) -> C, _ fa: (A) -> C) -> C {
        switch value {
            case let .invalid(value): return fe(value)
            case let .valid(value): return fa(value)
        }
    }
    
    /// Checks if this value is valid.
    public var isValid: Bool {
        return fold(constant(false), constant(true))
    }
    
    /// Checks if this value is invalid.
    public var isInvalid: Bool {
        return !isValid
    }
    
    /// Checks if the valid value in this `Validated` matches a predicate.
    ///
    /// - Parameter predicate: Predicate to match the valid values.
    /// - Returns: `false` if the contained value is invalid or does not match the predicate; `true` otherwise.
    public func exists(_ predicate: (A) -> Bool) -> Bool {
        return fold(constant(false), predicate)
    }
    
    /// Converts this value to an `Either` value.
    ///
    /// - Returns: An `Either.left` if this value is invalid, or an `Either.right` if this value is valid.
    public func toEither() -> Either<E, A> {
        return fold(Either.left, Either.right)
    }
    
    /// Converts this value to an `Option` value.
    ///
    /// - Returns: An `Option.none` if this value is invalid, or an `Option.some` if this value is valid.
    public func toOption() -> Option<A> {
        return fold(constant(Option.none()), Option.some)
    }
    
    /// Converts this value to an `Array` value.
    ///
    /// - Returns: An empty array if this value is invalid, or a singleton array if this value is valid.
    public func toArray() -> [A] {
        return fold(constant([]), { a in [a] })
    }

    /// Wraps the invalid values of this type into a `NonEmptyArray`.
    ///
    /// - Returns: A value that is equivalent to the original one but wraps the invalid value in a `NonEmptyArray`.
    public func toValidatedNEA() -> Validated<NEA<E>, A> {
        return fold({ e in Validated<NEA<E>, A>.invalid(NEA.fix(NEA.pure(e))) }, Validated<NEA<E>, A>.valid)
    }
    
    /// Applies a function in the `Either` context to this value.
    ///
    /// It uses the isomorphism between `Either` and `Validated`, mapping left to invalid and right to valid.
    ///
    /// - Parameter f: A closure in the `Either` context.
    /// - Returns: Transformation of this validated value with the provided closure.
    public func withEither<EE, B>(_ f: (Either<E, A>) -> Either<EE, B>) -> Validated<EE, B> where EE: Semigroup {
        return Validated<EE, B>.fix(Validated<EE, B>.fromEither(f(self.toEither())))
    }
    
    /// Swaps the valid and invalid types.
    ///
    /// - Returns: A valid value if it was invalid, and vice versa.
    public func swap() -> Validated<A, E> {
        return fold(Validated<A, E>.valid, Validated<A, E>.invalid)
    }
    
    /// Obtains the valid value or a default value for the invalid case.
    ///
    /// - Parameter defaultValue: Default value for the invalid case.
    /// - Returns: Valid value or default value otherwise.
    public func getOrElse(_ defaultValue: A) -> A {
        return fold(constant(defaultValue), id)
    }
    
    /// Obtains the valid value or maps the invalid value.
    ///
    /// - Parameter f: Mapping function for invalid values.
    /// - Returns: The valid value or the mapped invalid value.
    public func valueOr(_ f: (E) -> A) -> A {
        return fold(f, id)
    }

    /// Obtains this validated if is valid, or a default value if not.
    ///
    /// - Parameter defaultValue: Value to return if this value is invalid.
    /// - Returns: This value if it is valid, or the default one otherwise.
    public func orElse(_ defaultValue: Validated<E, A>) -> Validated<E, A> {
        return fold(constant(defaultValue), Validated.valid)
    }
    
    /// Obtains the valid value or nil if it is not present
    public var orNil: A? {
        return fold(constant(nil), id)
    }
    
    /// Obtains the valid value or none if it is not present
    public var orNone: Option<A> {
        return fold(constant(.none()), Option.some)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Validated.
public postfix func ^<E, A>(_ fa: ValidatedOf<E, A>) -> Validated<E, A> {
    return Validated.fix(fa)
}

private enum _Validated<A, B> {
    case invalid(A)
    case valid(B)
}

// MARK: Conformance of `Validated` to `CustomStringConvertible`
extension Validated: CustomStringConvertible {
    public var description: String {
        return fold({ e in "Invalid(\(e))" },
                    { a in "Valid(\(a))" })
    }
}

// MARK: Conformance of `Validated` to `CustomDebugStringConvertible`
extension Validated: CustomDebugStringConvertible where E : CustomDebugStringConvertible, A : CustomDebugStringConvertible {
    public var debugDescription: String {
        return fold({ error in "Invalid(\(error.debugDescription))" },
                    { value in "Valid(\(value.debugDescription))" })
    }
}

// MARK: Instance of `EquatableK` for `Validated`
extension ValidatedPartial: EquatableK where I: Equatable {
    public static func eq<A>(_ lhs: Kind<ValidatedPartial<I>, A>, _ rhs: Kind<ValidatedPartial<I>, A>) -> Bool where A : Equatable {
        let vl = Validated.fix(lhs)
        let vr = Validated.fix(rhs)
        return vl.fold({ le in vr.fold({ re in le == re }, constant(false)) },
                       { la in vr.fold(constant(false), { ra in la == ra }) })
    }
}

// MARK: Instance of `Functor` for `Validated`
extension ValidatedPartial: Functor {
    public static func map<A, B>(_ fa: Kind<ValidatedPartial<I>, A>, _ f: @escaping (A) -> B) -> Kind<ValidatedPartial<I>, B> {
        return Validated.fix(fa).fold(Validated.invalid, f >>> Validated.valid)
    }
}

// MARK: Instance of `Applicative` for `Validated`
extension ValidatedPartial: Applicative where I: Semigroup {
    public static func pure<A>(_ a: A) -> Kind<ValidatedPartial<I>, A> {
        return Validated.valid(a)
    }

    public static func ap<A, B>(_ ff: Kind<ValidatedPartial<I>, (A) -> B>, _ fa: Kind<ValidatedPartial<I>, A>) -> Kind<ValidatedPartial<I>, B> {
        let valA = Validated.fix(fa)
        let valF = Validated.fix(ff)
        return valA.fold({ e in valF.fold({ ee in Validated.invalid(e.combine(ee)) },
                                          { _ in Validated.invalid(e) }) },
                         { a in valF.fold({ ee in Validated.invalid(ee) },
                                          { f in Validated.valid(f(a)) }) })
    }
}

// MARK: Instance of `Selective` for `Validated`
extension ValidatedPartial: Selective where I: Semigroup {
    public static func select<A, B>(_ fab: Kind<ValidatedPartial<I>, Either<A, B>>, _ f: Kind<ValidatedPartial<I>, (A) -> B>) -> Kind<ValidatedPartial<I>, B> {
        return Validated.fix(fab).fold(
            { e in Validated.invalid(e) },
            { eab in eab.fold({ a in map(f, { ff in ff(a) }) },
                              { b in Validated.valid(b) })
            })
    }
}

// MARK: Instance of `ApplicativeError` for `Validated`
extension ValidatedPartial: ApplicativeError where I: Semigroup {
    public typealias E = I

    public static func raiseError<A>(_ e: I) -> Kind<ValidatedPartial<I>, A> {
        return Validated.invalid(e)
    }

    public static func handleErrorWith<A>(_ fa: Kind<ValidatedPartial<I>, A>, _ f: @escaping (I) -> Kind<ValidatedPartial<I>, A>) -> Kind<ValidatedPartial<I>, A> {
        return Validated.fix(fa).fold(f, Validated.valid)
    }
}

// MARK: Instance of `Foldable` for `Validated`
extension ValidatedPartial: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ValidatedPartial<I>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return Validated.fix(fa).fold(constant(b), { a in f(b, a) })
    }

    public static func foldRight<A, B>(_ fa: Kind<ValidatedPartial<I>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Validated.fix(fa).fold(constant(b), { a in f(a, b) })
    }
}

// MARK: Instance of `Traverse` for `Validated`
extension ValidatedPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ValidatedPartial<I>, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ValidatedPartial<I>, B>> {
        return Validated.fix(fa).fold(Validated.invalid >>> G.pure,
                                      { a in G.map(f(a), Validated.valid) })
    }
}

// MARK: Instance of `SemigroupK` for `Validated`
extension ValidatedPartial: SemigroupK where I: Semigroup {
    public static func combineK<A>(_ x: Kind<ValidatedPartial<I>, A>, _ y: Kind<ValidatedPartial<I>, A>) -> Kind<ValidatedPartial<I>, A> {
        return Validated.fix(x).fold({ e in
            Validated.fix(y).fold({ ee in Validated.invalid(e.combine(ee)) },
                   Validated.valid) }, Validated.valid)
    }
}

// MARK: Instance of `Semigroup` for `Validated`
extension Validated: Semigroup where E: Semigroup, A: Semigroup {
    public func combine(_ other: Validated<E, A>) -> Validated<E, A> {
        return self.fold({ e1 in other.fold({ e2 in .invalid(e1.combine(e2)) }, { a2 in .invalid(e1) }) },
                         { a1 in other.fold({ e2 in .invalid(e2)}, { a2 in .valid(a1.combine(a2)) }) })
    }
}
