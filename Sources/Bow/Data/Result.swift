public extension Result {
    func toEither() -> Either<Failure, Success> {
        return fold(Either.left, Either.right)
    }

    func toTry() -> Try<Success> {
        return fold(Try.failure, Try.success)
    }

    func toValidated() -> Validated<Failure, Success> {
        return fold(Validated.invalid, Validated.valid)
    }

    func toOption() -> Option<Success> {
        return fold(constant(Option.none()), Option.some)
    }

    func fold<B>(_ ifFailure: @escaping (Failure) -> B,
                 _ ifSuccess: @escaping (Success) -> B) -> B {
        switch self {
        case let .failure(error): return ifFailure(error)
        case let .success(value): return ifSuccess(value)
        }
    }
}

public extension Either where A: Error {
    func toResult() -> Result<B, A> {
        return self.fold(Result.failure, Result.success)
    }
}

public extension Validated where E: Error {
    func toResult() -> Result<A, E> {
        return self.fold(Result.failure, Result.success)
    }
}
