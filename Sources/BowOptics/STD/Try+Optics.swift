import Foundation
import Bow

// MARK: Optics extensions
public extension Try {
    /// Provides a polymorphic prism focused on the success side of a Try.
    ///
    /// - Returns: A polymorphic prism focused on the success side of a Try.
    static func pSuccessPrism<B>() -> PPrism<Try<A>, Try<B>, A, B> {
        return PPrism<Try<A>, Try<B>, A, B>(
            getOrModify: { aTry in aTry.fold({ e in Either<Try<B>, A>.left(Try<B>.failure(e)) },
                                             { a in Either<Try<B>, A>.right(a) }) },
            reverseGet: Try<B>.success)
    }
    
    /// Provides a prism focused on the success side of a Try.
    static var successPrism: Prism<Try<A>, A> {
        return pSuccessPrism()
    }
    
    /// Provides a prism focused on the failure side of a Try.
    static var failurePrism: Prism<Try<A>, Error> {
        return Prism<Try<A>, Error>(
            getOrModify: { aTry in aTry.fold({ e in Either.right(e) },
                                             { a in Either.left(Try.success(a)) }) },
            reverseGet: Try.failure )
    }
    
    /// Provides a polymorphic Iso between Try and Either.
    ///
    /// - Returns: A polymorphic Iso between Try and Either.
    static func toPEither<B>() -> PIso<Try<A>, Try<B>, Either<Error, A>, Either<Error, B>> {
        return PIso<Try<A>, Try<B>, Either<Error, A>, Either<Error, B>>(
            get: { aTry in aTry.fold(Either<Error, A>.left, Either<Error, A>.right) },
            reverseGet: { either in either.fold(Try<B>.failure, Try<B>.success) })
    }
    
    /// Provides an Iso between Try and Either.
    static var toEither: Iso<Try<A>, Either<Error, A>> {
        return toPEither()
    }
    
    /// Provides a polymorphic Iso between Try and Validated.
    ///
    /// - Returns: A polymorphic Iso between Try and Validated.
    static func toPValidated<B>() -> PIso<Try<A>, Try<B>, Validated<Error, A>, Validated<Error, B>> {
        return PIso<Try<A>, Try<B>, Validated<Error, A>, Validated<Error, B>>(
            get: { aTry in aTry.fold(Validated<Error, A>.invalid, Validated<Error, A>.valid)},
            reverseGet: { validated in validated.fold(Try<B>.failure, Try<B>.success) })
    }
    
    /// Provides an Iso between Try and Validated.
    static var toValidated: Iso<Try<A>, Validated<Error, A>> {
        return toPValidated()
    }
}
