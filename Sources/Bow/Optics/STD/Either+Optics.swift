import Foundation

public extension Either {
    public static func toPValidated<C, D>() -> PIso<Either<A, B>, Either<C, D>, Validated<A, B>, Validated<C, D>> {
        return PIso<Either<A, B>, Either<C, D>, Validated<A, B>, Validated<C, D>>(
            get: { either in either.fold(Validated<A, B>.invalid, Validated<A, B>.valid) },
            reverseGet: { x in x.toEither() })
    }
    
    public static func toValidated() -> Iso<Either<A, B>, Validated<A, B>> {
        return toPValidated()
    }
}
