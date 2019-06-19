import Foundation
import Bow

public extension Option {
    static func toPOption<B>() -> PIso<Option<A>, Option<B>, A?, B?> {
        return PIso<Option<A>, Option<B>, A?, B?>(
            get: { x in x.toOptional() },
            reverseGet: Option<B>.fromOptional)
    }

    static var toOption: Iso<Option<A>, A?> {
        return toPOption()
    }

    static func PSomePrism<B>() -> PPrism<Option<A>, Option<B>, A, B> {
        return PPrism<Option<A>, Option<B>, A, B>(
            getOrModify: { option in
                option.fold({ Either<Option<B>, A>.left(Option<B>.none()) },
                            { a in Either<Option<B>, A>.right(a) })
        },
            reverseGet: Option<B>.some)
    }

    static var somePrism: Prism<Option<A>, A> {
        return PSomePrism()
    }

    static var nonePrism: Prism<Option<A>, ()> {
        return Prism<Option<A>, ()>(
            getOrModify: { option in
                option.fold({ Either<Option<A>, ()>.right(unit) },
                            { a in Either<Option<A>, ()>.left(Option<A>.some(a)) })
        },
            reverseGet: { Option<A>.none() })
    }

    static func toPEither<B>() -> PIso<Option<A>, Option<B>, Either<(), A>, Either<(), B>> {
        return PIso<Option<A>, Option<B>, Either<(), A>, Either<(), B>>(
            get: { option in option.fold({ Either.left(unit) },
                                         { a in Either.right(a) })
        },  reverseGet: { either in either.fold({ Option<B>.none() },
                                                { b in Option<B>.some(b) })})
    }

    static var toEither: Iso<Option<A>, Either<(), A>> {
        return toPEither()
    }
}
