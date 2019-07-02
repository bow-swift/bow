import Foundation
import Bow

// MARK: Optics extensions
public extension Either {
    /// Provides a polymorphic Iso between Either and Validated.
    ///
    /// - Returns: A polymorphic Iso between Either and Validated.
    static func toPValidated<C, D>() -> PIso<Either<A, B>, Either<C, D>, Validated<A, B>, Validated<C, D>> {
        return PIso<Either<A, B>, Either<C, D>, Validated<A, B>, Validated<C, D>>(
            get: { either in either.fold(Validated<A, B>.invalid, Validated<A, B>.valid) },
            reverseGet: { x in x.toEither() })
    }

    /// Provides an Iso between Either and Validated.
    static var toValidated: Iso<Either<A, B>, Validated<A, B>> {
        return toPValidated()
    }
    
    /// Provides a Prism focused on the left side of an Either.
    static var leftPrism: Prism<Either<A, B>, A> {
        return Prism(
            getOrModify: { either in either.fold(
                Either<Either<A, B>, A>.right,
                { b in Either<Either<A, B>, A>.left(.right(b)) }) },
            reverseGet: Either.left)
    }
    
    /// Provides a Prism focused on the right side of an Either.
    static var rightPrism: Prism<Either<A, B>, B> {
        return Prism(
            getOrModify: { either in either.fold(
                { a in Either<Either<A, B>, B>.left(.left(a)) },
                Either<Either<A, B>, B>.right) },
            reverseGet: Either.right)
    }
}
