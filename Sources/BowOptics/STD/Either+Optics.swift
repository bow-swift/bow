import Foundation
import Bow

public extension Either {
    static func toPValidated<C, D>() -> PIso<Either<A, B>, Either<C, D>, Validated<A, B>, Validated<C, D>> {
        return PIso<Either<A, B>, Either<C, D>, Validated<A, B>, Validated<C, D>>(
            get: { either in either.fold(Validated<A, B>.invalid, Validated<A, B>.valid) },
            reverseGet: { x in x.toEither() })
    }

    static var toValidated: Iso<Either<A, B>, Validated<A, B>> {
        return toPValidated()
    }
}
