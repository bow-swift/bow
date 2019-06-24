import Foundation
import Bow

// MARK: Optics extensions
public extension Result {
    /// Provides a prism focused on the success side of a Result.
    static var successPrism: Prism<Result<Success, Failure>, Success> {
        return Prism(
            getOrModify: { result in
                switch result {
                case let .success(s): return Either.right(s)
                case let .failure(e): return Either.left(.failure(e))
                }
            },
            reverseGet: Result.success)
    }
    
    /// Provides a prism focused on the failure side of a Result.
    static var failurePrism: Prism<Result<Success, Failure>, Failure> {
        return Prism(
            getOrModify: { result in
                switch result {
                case let .success(s): return Either.left(.success(s))
                case let .failure(e): return Either.right(e)
                }
            },
            reverseGet: Result.failure)
    }
    
    /// Provides an Iso between Result and Either.
    static var toEither: Iso<Result<Success, Failure>, Either<Failure, Success>> {
        return Iso(get: { x in x.toEither() },
                   reverseGet: { x in x.toResult() })
    }
    
    /// Provides an Iso between Result and Validated.
    static var toValidated: Iso<Result<Success, Failure>, Validated<Failure, Success>> {
        return Iso(get: { x in x.toValidated() },
                   reverseGet: { x in x.toResult() })
    }
}
