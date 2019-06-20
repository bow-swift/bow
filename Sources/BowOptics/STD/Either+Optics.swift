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
    
    static var leftPrism: Prism<Either<A, B>, A> {
        return Prism(
            getOrModify: { either in either.fold(
                Either<Either<A, B>, A>.right,
                { b in Either<Either<A, B>, A>.left(.right(b)) }) },
            reverseGet: Either.left)
    }
    
    static var rightPrism: Prism<Either<A, B>, B> {
        return Prism(
            getOrModify: { either in either.fold(
                { a in Either<Either<A, B>, B>.left(.left(a)) },
                Either<Either<A, B>, B>.right) },
            reverseGet: Either.right)
    }
}
