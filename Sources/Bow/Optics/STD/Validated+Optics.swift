import Foundation

public extension Validated {
    public static func toPEither<E2, B>() -> PIso<Validated<E, A>, Validated<E2, B>, Either<E, A>, Either<E2, B>> {
        return PIso<Validated<E, A>, Validated<E2, B>, Either<E, A>, Either<E2, B>>(
            get: { validated in validated.fold(Either<E, A>.left,
                                               Either<E, A>.right) },
            reverseGet: { either in either.fold(Validated<E2, B>.invalid,
                                                Validated<E2, B>.valid) })
    }
    
    public static func toEither() -> Iso<Validated<E, A>, Either<E, A>> {
        return toPEither()
    }
    
    public static func toPTry<B>() -> PIso<Validated<Error, A>, Validated<Error, B>, Try<A>, Try<B>> {
        return PIso<Validated<Error, A>, Validated<Error, B>, Try<A>, Try<B>>(
            get: { validated in validated.fold(Try<A>.failure,
                                               Try<A>.success) },
            reverseGet: Validated<Error, B>.fromTry )
    }
    
    public static func toTry() -> Iso<Validated<Error, A>, Try<A>> {
        return toPTry()
    }
}
