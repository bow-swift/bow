public extension Result {
    
    /// Converts this Result into an Either value.
    ///
    /// - Returns: An Either.left if this is a Result.failure, or an Either.right if this is a Result.success
    func toEither() -> Either<Failure, Success> {
        return fold(Either.left, Either.right)
    }

    /// Converts this Result into a Try value.
    ///
    /// - Returns: A Try.failure if this is a Result.failure, or a Try.success if this is a Result.success
    func toTry() -> Try<Success> {
        return fold(Try.failure, Try.success)
    }
    
    /// Converts this Result into a Validated value.
    ///
    /// - Returns: A Validated.invalid if this is a Result.failure, or a Validated.valid if this is a Result.success.
    func toValidated() -> Validated<Failure, Success> {
        return fold(Validated.invalid, Validated.valid)
    }
    
    /// Converts this Result into a ValidatedNEA value.
    ///
    /// - Returns: A Validated.invalid with a NonEmptyArray of the Failure type if this is a Result.failure, or a Validated.valid if this is a Result.success.
    func toValidatedNEA() -> ValidatedNEA<Failure, Success> {
        return toValidated().toValidatedNEA()
    }

    /// Converts this Result into an Option value.
    ///
    /// - Returns: Option.none if this is a Result.failure, or Option.some if this is a Result.success.
    func toOption() -> Option<Success> {
        return fold(constant(Option.none()), Option.some)
    }

    /// Applies the corresponding closure based on the value contained in this result.
    ///
    /// - Parameters:
    ///   - ifFailure: Closure to be applied if this is a Result.failure.
    ///   - ifSuccess: Closure to be applied if this is a Result.success.
    /// - Returns: Output of the execution of the corresponding closure, based on the internal value of this Result.
    func fold<B>(_ ifFailure: @escaping (Failure) -> B,
                 _ ifSuccess: @escaping (Success) -> B) -> B {
        switch self {
        case let .failure(error): return ifFailure(error)
        case let .success(value): return ifSuccess(value)
        }
    }
}

// MARK: Conversion to Result when the left type conforms to Error

public extension Either where A: Error {
    /// Converts this Either into a Result value.
    ///
    /// - Returns: A Result.success if this is an Either.right, or a Result.failure if this is an Either.left.
    func toResult() -> Result<B, A> {
        return self.fold(Result.failure, Result.success)
    }
}

// MARK: Conversion to Result when the invalid type conforms to Error

public extension Validated where E: Error {
    /// Converts this Validated into a Result value.
    ///
    /// - Returns: A Result.success if this is a Validated.valid, or a Result.failure if this is a Validated.invalid.
    func toResult() -> Result<A, E> {
        return self.fold(Result.failure, Result.success)
    }
}
