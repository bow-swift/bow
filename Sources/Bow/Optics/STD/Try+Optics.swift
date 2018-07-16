import Foundation

public extension Try {
    public static func pSuccessPrism<B>() -> PPrism<Try<A>, Try<B>, A, B> {
        return PPrism<Try<A>, Try<B>, A, B>(
            getOrModify: { aTry in aTry.fold({ e in Either<Try<B>, A>.left(Try<B>.failure(e)) },
                                             { a in Either<Try<B>, A>.right(a) }) },
            reverseGet: Try<B>.success)
    }
    
    public static func successPrism() -> Prism<Try<A>, A> {
        return pSuccessPrism()
    }
    
    public static func failurePrism() -> Prism<Try<A>, Error> {
        return Prism<Try<A>, Error>(
            getOrModify: { aTry in aTry.fold({ e in Either.right(e) },
                                             { a in Either.left(Try.success(a)) }) },
            reverseGet: Try.failure )
    }
    
    public static func toPEither<B>() -> PIso<Try<A>, Try<B>, Either<Error, A>, Either<Error, B>> {
        return PIso<Try<A>, Try<B>, Either<Error, A>, Either<Error, B>>(
            get: { aTry in aTry.fold(Either<Error, A>.left, Either<Error, A>.right) },
            reverseGet: { either in either.fold(Try<B>.failure, Try<B>.success) })
    }
    
    public static func toEither() -> Iso<Try<A>, Either<Error, A>> {
        return toPEither()
    }
    
    public static func toPValidated<B>() -> PIso<Try<A>, Try<B>, Validated<Error, A>, Validated<Error, B>> {
        return PIso<Try<A>, Try<B>, Validated<Error, A>, Validated<Error, B>>(
            get: { aTry in aTry.fold(Validated<Error, A>.invalid, Validated<Error, A>.valid)},
            reverseGet: { validated in validated.fold(Try<B>.failure, Try<B>.success) })
    }
    
    public static func toValidated() -> Iso<Try<A>, Validated<Error, A>> {
        return toPValidated()
    }
}
