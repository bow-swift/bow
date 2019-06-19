import Foundation
import Bow

public extension Try {
    static func pSuccessPrism<B>() -> PPrism<Try<A>, Try<B>, A, B> {
        return PPrism<Try<A>, Try<B>, A, B>(
            getOrModify: { aTry in aTry.fold({ e in Either<Try<B>, A>.left(Try<B>.failure(e)) },
                                             { a in Either<Try<B>, A>.right(a) }) },
            reverseGet: Try<B>.success)
    }
    
    static var successPrism: Prism<Try<A>, A> {
        return pSuccessPrism()
    }
    
    static var failurePrism: Prism<Try<A>, Error> {
        return Prism<Try<A>, Error>(
            getOrModify: { aTry in aTry.fold({ e in Either.right(e) },
                                             { a in Either.left(Try.success(a)) }) },
            reverseGet: Try.failure )
    }
    
    static func toPEither<B>() -> PIso<Try<A>, Try<B>, Either<Error, A>, Either<Error, B>> {
        return PIso<Try<A>, Try<B>, Either<Error, A>, Either<Error, B>>(
            get: { aTry in aTry.fold(Either<Error, A>.left, Either<Error, A>.right) },
            reverseGet: { either in either.fold(Try<B>.failure, Try<B>.success) })
    }
    
    static var toEither: Iso<Try<A>, Either<Error, A>> {
        return toPEither()
    }
    
    static func toPValidated<B>() -> PIso<Try<A>, Try<B>, Validated<Error, A>, Validated<Error, B>> {
        return PIso<Try<A>, Try<B>, Validated<Error, A>, Validated<Error, B>>(
            get: { aTry in aTry.fold(Validated<Error, A>.invalid, Validated<Error, A>.valid)},
            reverseGet: { validated in validated.fold(Try<B>.failure, Try<B>.success) })
    }
    
    static var toValidated: Iso<Try<A>, Validated<Error, A>> {
        return toPValidated()
    }
}
