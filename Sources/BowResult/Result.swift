import Result
import Bow

public extension Result {
    public func toEither() -> Either<Error, Value> {
        return fold(Either.left, Either.right)
    }
    
    public func toTry() -> Try<Value> {
        return fold(Try.failure, Try.success)
    }
    
    public func toValidated() -> Validated<Error, Value> {
        return fold(Validated.invalid, Validated.valid)
    }
    
    public func toOption() -> Option<Value> {
        return fold(constant(Option.none()), Option.some)
    }
    
    func fold<B>(_ ifFailure : @escaping (Error) -> B,
                 _ ifSuccess : @escaping (Value) -> B) -> B {
        switch self {
        case let .failure(error): return ifFailure(error)
        case let .success(value): return ifSuccess(value)
        }
    }
}

public extension Either where A : Error {
    public func toResult() -> Result<B, A> {
        return self.fold(Result.init(error:), Result.init(value:))
    }
}

public extension Validated where E : Error {
    public func toResult() -> Result<A, E> {
        return self.fold(Result.init(error:), Result.init(value:))
    }
}
