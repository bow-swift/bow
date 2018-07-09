import Foundation

public extension Maybe {
    public static func toPOption<B>() -> PIso<Maybe<A>, Maybe<B>, A?, B?> {
        return PIso<Maybe<A>, Maybe<B>, A?, B?>(
            get: { x in x.toOption() },
            reverseGet: Maybe<B>.fromOption)
    }
    
    public static func toOption() -> Iso<Maybe<A>, A?> {
        return toPOption()
    }
    
    public static func PSomePrism<B>() -> PPrism<Maybe<A>, Maybe<B>, A, B> {
        return PPrism<Maybe<A>, Maybe<B>, A, B>(
            getOrModify: { maybe in
                maybe.fold({ Either<Maybe<B>, A>.left(Maybe<B>.none()) },
                           { a in Either<Maybe<B>, A>.right(a) })
        },
            reverseGet: Maybe<B>.some)
    }
    
    public static func somePrism() -> Prism<Maybe<A>, A> {
        return PSomePrism()
    }
    
    public static func nonePrism() -> Prism<Maybe<A>, Unit> {
        return Prism<Maybe<A>, Unit>(
            getOrModify: { maybe in
                maybe.fold({ Either<Maybe<A>, Unit>.right(unit) },
                           { a in Either<Maybe<A>, Unit>.left(Maybe<A>.some(a)) })
        },
            reverseGet: { Maybe<A>.none() })
    }
    
    public static func toPEither<B>() -> PIso<Maybe<A>, Maybe<B>, Either<Unit, A>, Either<Unit, B>> {
        return PIso<Maybe<A>, Maybe<B>, Either<Unit, A>, Either<Unit, B>>(
            get: { maybe in maybe.fold({ Either.left(unit) },
                                       { a in Either.right(a) })
        },  reverseGet: { either in either.fold({ Maybe<B>.none() },
                                                { b in Maybe<B>.some(b) })})
    }
    
    public static func toEither() -> Iso<Maybe<A>, Either<Unit, A>> {
        return toPEither()
    }
}
