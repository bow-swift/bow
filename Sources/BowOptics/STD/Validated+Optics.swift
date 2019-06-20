import Foundation
import Bow

public extension Validated {
    static func toPEither<E2, B>() -> PIso<Validated<E, A>, Validated<E2, B>, Either<E, A>, Either<E2, B>> {
        return PIso<Validated<E, A>, Validated<E2, B>, Either<E, A>, Either<E2, B>>(
            get: { validated in validated.fold(Either<E, A>.left,
                                               Either<E, A>.right) },
            reverseGet: { either in either.fold(Validated<E2, B>.invalid,
                                                Validated<E2, B>.valid) })
    }

    static var toEither: Iso<Validated<E, A>, Either<E, A>> {
        return toPEither()
    }

    static func toPTry<B>() -> PIso<Validated<Error, A>, Validated<Error, B>, Try<A>, Try<B>> {
        return PIso<Validated<Error, A>, Validated<Error, B>, Try<A>, Try<B>>(
            get: { validated in validated.fold(Try<A>.failure,
                                               Try<A>.success) },
            reverseGet: Validated<Error, B>.fromTry )
    }

    static var toTry: Iso<Validated<Error, A>, Try<A>> {
        return toPTry()
    }
    
    static func pValidPrism<B>() -> PPrism<Validated<E, A>, Validated<E, B>, A, B> {
        return PPrism(
            getOrModify: { validated in validated.fold({ e in Either.left(Validated<E, B>.invalid(e)) }, Either.right) },
            reverseGet: Validated<E, B>.valid)
    }
    
    static var validPrism: Prism<Validated<E, A>, A> {
        return pValidPrism()
    }
    
    static func pInvalidPrism<EE>() -> PPrism<Validated<E, A>, Validated<EE, A>, E, EE> {
        return PPrism(
            getOrModify: { validated in validated.fold(Either.right, { a in Either.left(Validated<EE, A>.valid(a)) } ) },
            reverseGet: Validated<EE, A>.invalid)
    }
    
    static var invalidPrism: Prism<Validated<E, A>, E> {
        return pInvalidPrism()
    }
}
