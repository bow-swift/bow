import Foundation
import Result

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
