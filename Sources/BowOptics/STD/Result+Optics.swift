import Foundation
import Bow

public extension Result {
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
}
