import Foundation
import Bow

public extension Option {
    public static func toPOption<B>() -> PIso<Option<A>, Option<B>, A?, B?> {
        return PIso<Option<A>, Option<B>, A?, B?>(
            get: { x in x.toOptional() },
            reverseGet: Option<B>.fromOptional)
    }
    
    public static func toOption() -> Iso<Option<A>, A?> {
        return toPOption()
    }
    
    public static func PSomePrism<B>() -> PPrism<Option<A>, Option<B>, A, B> {
        return PPrism<Option<A>, Option<B>, A, B>(
            getOrModify: { option in
                option.fold({ Either<Option<B>, A>.left(Option<B>.none()) },
                            { a in Either<Option<B>, A>.right(a) })
        },
            reverseGet: Option<B>.some)
    }
    
    public static func somePrism() -> Prism<Option<A>, A> {
        return PSomePrism()
    }
    
    public static func nonePrism() -> Prism<Option<A>, ()> {
        return Prism<Option<A>, ()>(
            getOrModify: { option in
                option.fold({ Either<Option<A>, ()>.right(unit) },
                            { a in Either<Option<A>, ()>.left(Option<A>.some(a)) })
        },
            reverseGet: { Option<A>.none() })
    }
    
    public static func toPEither<B>() -> PIso<Option<A>, Option<B>, Either<(), A>, Either<(), B>> {
        return PIso<Option<A>, Option<B>, Either<(), A>, Either<(), B>>(
            get: { option in option.fold({ Either.left(unit) },
                                         { a in Either.right(a) })
        },  reverseGet: { either in either.fold({ Option<B>.none() },
                                                { b in Option<B>.some(b) })})
    }
    
    public static func toEither() -> Iso<Option<A>, Either<(), A>> {
        return toPEither()
    }
}
