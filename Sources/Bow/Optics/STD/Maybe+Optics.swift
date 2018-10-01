import Foundation

public extension Option {
    public static func toPOption<B>() -> PIso<Option<A>, Option<B>, A?, B?> {
        return PIso<Option<A>, Option<B>, A?, B?>(
            get: { x in x.toOption() },
            reverseGet: Option<B>.fromOption)
    }
    
    public static func toOption() -> Iso<Option<A>, A?> {
        return toPOption()
    }
    
    public static func PSomePrism<B>() -> PPrism<Option<A>, Option<B>, A, B> {
        return PPrism<Option<A>, Option<B>, A, B>(
            getOrModify: { maybe in
                maybe.fold({ Either<Option<B>, A>.left(Option<B>.none()) },
                           { a in Either<Option<B>, A>.right(a) })
        },
            reverseGet: Option<B>.some)
    }
    
    public static func somePrism() -> Prism<Option<A>, A> {
        return PSomePrism()
    }
    
    public static func nonePrism() -> Prism<Option<A>, Unit> {
        return Prism<Option<A>, Unit>(
            getOrModify: { maybe in
                maybe.fold({ Either<Option<A>, Unit>.right(unit) },
                           { a in Either<Option<A>, Unit>.left(Option<A>.some(a)) })
        },
            reverseGet: { Option<A>.none() })
    }
    
    public static func toPEither<B>() -> PIso<Option<A>, Option<B>, Either<Unit, A>, Either<Unit, B>> {
        return PIso<Option<A>, Option<B>, Either<Unit, A>, Either<Unit, B>>(
            get: { maybe in maybe.fold({ Either.left(unit) },
                                       { a in Either.right(a) })
        },  reverseGet: { either in either.fold({ Option<B>.none() },
                                                { b in Option<B>.some(b) })})
    }
    
    public static func toEither() -> Iso<Option<A>, Either<Unit, A>> {
        return toPEither()
    }
}
