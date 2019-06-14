import Foundation

/// Models an error in an invocation to some methods of `Try`.
///
/// - illegalState: The value is in an illegal state when an operation is invoked.
/// - predicateDoesNotMatch: The value does not match the provided predicate.
/// - unsupportedOperation: The invoked operation is unsupported for the value receiving it.
public enum TryError: Error {
    case illegalState
    case predicateDoesNotMatch
    case unsupportedOperation(String)
}

/// Witness for the `Try<A>` data type. To be used in simulated Higher Kinded Types.
public final class ForTry {}

/// Higher Kinded Type alias to improve readability over `Kind<ForTry, A>`.
public typealias TryOf<A> = Kind<ForTry, A>

/// Describes the result of an operation that may have thrown errors or succeeded. The type parameter corresponds to the result type of the operation.
public final class Try<A>: TryOf<A> {
    private let value: _Try<A>

    /// Creates a successful Try value.
    ///
    /// - Parameter value: Value to be wrapped in a successful Try.
    /// - Returns: A `Try` value wrapping the successful value.
    public static func success(_ value: A) -> Try<A> {
        return Try(.success(value))
    }
    
    /// Creates a failed Try value.
    ///
    /// - Parameter error: An error.
    /// - Returns: A `Try` value wrapping the error.
    public static func failure(_ error: Error) -> Try<A> {
        return Try(.failure(error))
    }

    /// Creates a failed Try value.
    ///
    /// - Parameter error: An error.
    /// - Returns: A `Try` value wrapping the error.
    public static func raise(_ error: Error) -> Try<A> {
        return failure(error)
    }
    
    /// Invokes a closure that may throw errors and wraps the result in a `Try` value.
    ///
    /// - Parameter f: Closure to be invoked.
    /// - Returns: A `Try` value wrapping the result of the invocation or any error that it may have thrown.
    public static func invoke(_ f: () throws -> A) -> Try<A> {
        do {
            let result = try f()
            return success(result)
        } catch let error {
            return failure(error)
        }
    }

    private init(_ value: _Try<A>) {
        self.value = value
    }

    /// Safe downcast.
    ///
    /// - Parameter fa: Value in the higher-kind form.
    /// - Returns: Value cast to Try.
    public static func fix(_ fa: TryOf<A>) -> Try<A> {
        return fa as! Try<A>
    }
    
    /// Applies the provided closures based on the content of this `Try` value.
    ///
    /// - Parameters:
    ///   - fe: Closure to apply if the contained value in this `Try` is an error.
    ///   - fa: Closure to apply if the contained value in this `Try` is a successful value.
    /// - Returns: Result of applying the corresponding closure to this value.
    public func fold<B>(_ fe: (Error) -> B, _ fa: (A) throws -> B) -> B {
        switch value {
        case let .success(a):
            do {
                return try fa(a)
            } catch let error {
                return fe(error)
            }
        case let .failure(e): return fe(e)
        }
    }

    /// Checks if this value is a failure.
    public var isFailure: Bool {
        return fold(constant(true), constant(false))
    }

    /// Checks if this value is a success.
    public var isSuccess: Bool {
        return !isFailure
    }

    /// Obtains the wrapped error in this `Try`.
    ///
    /// - Returns: A successful error or a failure with `TryError.unsupportedOperation` if this value was not an error.
    public func failed() -> Try<Error> {
        return fold(Try<Error>.success,
                    { _ in Try<Error>.failure(TryError.unsupportedOperation("Success.failed"))})
    }
    
    /// Obtains the value wrapped in this `Try` or a default value if it contains an error.
    ///
    /// - Parameter defaultValue: Default value for the failure case.
    /// - Returns: Value wrapped in this `Try`, or the default value if it was an error.
    public func getOrElse(_ defaultValue: A) -> A {
        return fold(constant(defaultValue), id)
    }
    
    /// Attempts to recover if the contained value in this `Try` is an error.
    ///
    /// - Parameter f: Recovery function.
    /// - Returns: A `Try` value from the recovery, or the original value if it was not an error.
    public func recoverWith(_ f: (Error) -> Try<A>) -> Try<A> {
        return fold(f, Try.success)
    }
    
    /// Recovers if the contained value in this `Try` is an error.
    ///
    /// - Parameter f: Recovery function.
    /// - Returns: A `Try` value from the recovery, or the original value if it was not an error.
    public func recover(_ f: @escaping (Error) -> A) -> Try<A> {
        return fold(f >>> Try.success, Try.success)
    }

    /// Converts this value to a failure if the transformation provides no value.
    ///
    /// - Parameter f: Transformation function.
    /// - Returns: A failure if the transformation of this value provides no result, or a success with the result of the transformation.
    public func mapFilter<B>(_ f: @escaping (A) -> Option<B>) -> Try<B> {
        return self.flatMap { a in f(a).fold(constant(Try<B>.raiseError(TryError.predicateDoesNotMatch)), Try<B>.pure) }^
    }

    /// Converts this value to an `Option`.
    ///
    /// - Returns: `Option.some` if this value is a success, or `Option.none` otherwise.
    public func toOption() -> Option<A> {
        return fold(constant(Option.none()), Option.some)
    }

    /// Converts this value to an `Either`.
    ///
    /// - Returns: A right value if this value is a success, or a left value if it contains an error.
    public func toEither() -> Either<Error, A> {
        return fold(Either.left, Either.right)
    }

    /// Obtains the value of this success or the provided default one if it is a failure.
    ///
    /// - Parameter defaultValue: Function providing the default value.
    /// - Returns: Wrapped value in this success, or default value otherwise.
    public func getOrDefault(_ defaultValue: @escaping @autoclosure () -> A) -> A {
        return fold(constant(defaultValue()), id)
    }

    /// Obtains the value of this success or nil if it is a failure.
    ///
    /// - Returns: Wrapped value in this success, or nil otherwise.
    public func orNil() -> A? {
        return fold(constant(nil), id)
    }

    /// Obtains this value or the provided default `Try` if it is a failure.
    ///
    /// - Parameter f: Function providing the default value.
    /// - Returns: This value if it is a success, or the default provided one otherwise.
    public func orElse(_ f: @escaping @autoclosure () -> Try<A>) -> Try<A> {
        return fold(constant(f()), Try.success)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Try.
public postfix func ^<A>(_ fa: TryOf<A>) -> Try<A> {
    return Try.fix(fa)
}

private enum _Try<A> {
    case success(A)
    case failure(Error)
}

// MARK: Conformance of `Try` to `CustomStringConvertible`
extension Try: CustomStringConvertible {
    public var description : String {
        return fold({ error in "Failure(\(error))" },
                    { value in "Success(\(value))" })
    }
}

// MARK: Conformance of `Try` to `CustomDebugStringConvertible`
extension Try: CustomDebugStringConvertible where A: CustomDebugStringConvertible {
    public var debugDescription: String {
        return fold({ error in "Failure(\(error))" },
                    { value in "Success(\(value.debugDescription))" })
    }
}

// MARK: Instance of `EquatableK` for `Try`
extension ForTry: EquatableK {
    public static func eq<A>(_ lhs: Kind<ForTry, A>, _ rhs: Kind<ForTry, A>) -> Bool where A : Equatable {
        let tl = Try.fix(lhs)
        let tr = Try.fix(rhs)
        return tl.fold({ aError in tr.fold({ bError in "\(aError)" == "\(bError)"}, constant(false))},
                       { a in tr.fold(constant(false), { b in a == b }) })
    }
}

// MARK: Instance of `Functor` for `Try`
extension ForTry: Functor {
    public static func map<A, B>(_ fa: Kind<ForTry, A>, _ f: @escaping (A) -> B) -> Kind<ForTry, B> {
        return Try.fix(fa).fold(Try.failure, Try.success <<< f)
    }
}

// MARK: Instance of `Applicative` for `Try`
extension ForTry: Applicative {
    public static func pure<A>(_ a: A) -> Kind<ForTry, A> {
        return Try.success(a)
    }
}

// MARK: Instance of `Selective` for `Try`
extension ForTry: Selective {}

// MARK: Instance of `Monad` for `Try`
extension ForTry: Monad {
    public static func flatMap<A, B>(_ fa: Kind<ForTry, A>, _ f: @escaping (A) -> Kind<ForTry, B>) -> Kind<ForTry, B> {
        let trya = Try<A>.fix(fa)
        return trya.fold(Try<B>.raise, f)
    }

    public static func tailRecM<A, B>(_ a: A, _ f: @escaping (A) -> Kind<ForTry, Either<A, B>>) -> Kind<ForTry, B> {
        return Try.fix(f(a)).fold(Try<B>.raise,
             { either in
                either.fold({ a in tailRecM(a, f)},
                            Try<B>.pure)
        })
    }
}

// MARK: Instance of `ApplicativeError` for `Try`
extension ForTry: ApplicativeError {
    public typealias E = Error

    public static func raiseError<A>(_ e: Error) -> Kind<ForTry, A> {
        return Try.failure(e)
    }

    public static func handleErrorWith<A>(_ fa: Kind<ForTry, A>, _ f: @escaping (Error) -> Kind<ForTry, A>) -> Kind<ForTry, A> {
        return Try.fix(fa).recoverWith({ e in Try.fix(f(e)) })
    }
}

// MARK: Instance of `MonadError` for `Try`
extension ForTry: MonadError {}

// MARK: Instance of `Foldable` for `Try`
extension ForTry: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ForTry, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return Try.fix(fa).fold(constant(b),
                                { a in f(b, a) })
    }

    public static func foldRight<A, B>(_ fa: Kind<ForTry, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Try.fix(fa).fold(constant(b),
                                { a in f(a, b) })
    }
}

// MARK: Instance of `Traverse` for `Try`
extension ForTry: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ForTry, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ForTry, B>> {
        return Try.fix(fa).fold({ _ in G.pure(Try.raise(TryError.illegalState)) },
                                { a in G.map(f(a), { b in Try.invoke{ b } }) })
    }
}

// MARK: Instance of `FunctorFilter` for `Try`
extension ForTry: FunctorFilter {
    public static func mapFilter<A, B>(_ fa: Kind<ForTry, A>, _ f: @escaping (A) -> Kind<ForOption, B>) -> Kind<ForTry, B> {
        return Try.fix(fa).flatMap { a in
            f(a)^.fold(constant(raiseError(TryError.predicateDoesNotMatch)), pure)
        }
    }
}


// MARK: Instance of `Semigroup` for `Try`
extension Try: Semigroup where A: Semigroup {
    public func combine(_ other: Try<A>) -> Try<A> {
        return self.fold(constant(other),
                         { a in other.fold(constant(Try.success(a)),
                                           { b in Try.success(a.combine(b)) })
                         })
    }
}

// MARK: Instance of `Monoid` for `Try`
extension Try: Monoid where A: Monoid {
    public static func empty() -> Try<A> {
        return Try.failure(TryError.illegalState)
    }
}
