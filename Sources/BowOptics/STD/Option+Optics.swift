import Foundation
import Bow

// MARK: Optics extensions
public extension Option {
    /// Provides a polymorphic Iso between Option and Swift Optional.
    ///
    /// - Returns: A polymorphic Iso between Option and Swift Optional.
    static func toPOption<B>() -> PIso<Option<A>, Option<B>, A?, B?> {
        return PIso<Option<A>, Option<B>, A?, B?>(
            get: { x in x.toOptional() },
            reverseGet: Option<B>.fromOptional)
    }

    /// Provides an Iso between Option and Swift Optional.
    static var toOption: Iso<Option<A>, A?> {
        return toPOption()
    }

    /// Provides a polymorphic prism focused on the some side of an Option.
    ///
    /// - Returns: A polymorphic prism focused on the some side of an Option.
    static func pSomePrism<B>() -> PPrism<Option<A>, Option<B>, A, B> {
        return PPrism<Option<A>, Option<B>, A, B>(
            getOrModify: { option in
                option.fold({ Either<Option<B>, A>.left(Option<B>.none()) },
                            { a in Either<Option<B>, A>.right(a) })
        },
            reverseGet: Option<B>.some)
    }

    /// Provides a prism focused on the some side of an Option.
    static var somePrism: Prism<Option<A>, A> {
        return pSomePrism()
    }

    /// Provides a prism focused on the none side of an Option.
    static var nonePrism: Prism<Option<A>, ()> {
        return Prism<Option<A>, ()>(
            getOrModify: { option in
                option.fold({ Either<Option<A>, ()>.right(unit) },
                            { a in Either<Option<A>, ()>.left(Option<A>.some(a)) })
        },
            reverseGet: { Option<A>.none() })
    }

    /// Provides a polymorphic Iso between Option and Either.
    ///
    /// - Returns: A polymorphic Iso between Option and Either.
    static func toPEither<B>() -> PIso<Option<A>, Option<B>, Either<(), A>, Either<(), B>> {
        return PIso<Option<A>, Option<B>, Either<(), A>, Either<(), B>>(
            get: { option in option.fold({ Either.left(unit) },
                                         { a in Either.right(a) })
        },  reverseGet: { either in either.fold({ Option<B>.none() },
                                                { b in Option<B>.some(b) })})
    }

    /// Provides a polymorphic Iso between Option and Either.
    static var toEither: Iso<Option<A>, Either<(), A>> {
        return toPEither()
    }
}
