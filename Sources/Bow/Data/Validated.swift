import Foundation

public final class ForValidated {}
public final class ValidatedPartial<I>: Kind<ForValidated, I> {}
public typealias ValidatedOf<E, A> = Kind<ValidatedPartial<E>, A>

public class Validated<E, A>: ValidatedOf<E, A> {
    public static func valid(_ value: A) -> Validated<E, A> {
        return Valid(value)
    }
    
    public static func invalid(_ value: E) -> Validated<E, A> {
        return Invalid(value)
    }
    
    public static func fromTry(_ t: Try<A>) -> Validated<Error, A> {
        return t.fold(Validated<Error, A>.invalid, Validated<Error, A>.valid)
    }
    
    public static func fromOption(_ m: Option<A>, ifNone: @escaping () -> E) -> Validated<E, A> {
        return m.fold(ifNone >>> Validated<E, A>.invalid, Validated<E, A>.valid)
    }
    
    public static func fix(_ fa: ValidatedOf<E, A>) -> Validated<E, A> {
        return fa as! Validated<E, A>
    }
    
    public func fold<C>(_ fe: (E) -> C, _ fa: (A) -> C) -> C {
        switch(self) {
            case let invalid as Invalid<E, A>: return fe(invalid.value)
            case let valid as Valid<E, A>: return fa(valid.value)
            default: fatalError("Validated must only have Valid and Invalid cases")
        }
    }
    
    public var isValid: Bool {
        return fold(constant(false), constant(true))
    }
    
    public var isInvalid: Bool {
        return !isValid
    }
    
    public func exists(_ predicate: (A) -> Bool) -> Bool {
        return fold(constant(false), predicate)
    }
    
    public func toEither() -> Either<E, A> {
        return fold(Either.left, Either.right)
    }
    
    public func toOption() -> Option<A> {
        return fold(constant(Option.none()), Option.some)
    }
    
    public func toArray() -> [A] {
        return fold(constant([]), { a in [a] })
    }
    
    public func withEither<EE, B>(_ f: (Either<E, A>) -> Either<EE, B>) -> Validated<EE, B> where EE: Semigroup {
        return Validated<EE, B>.fix(Validated<EE, B>.fromEither(f(self.toEither())))
    }
    
    public func swap() -> Validated<A, E> {
        return fold(Validated<A, E>.valid, Validated<A, E>.invalid)
    }
    
    public func getOrElse(_ defaultValue: A) -> A {
        return fold(constant(defaultValue), id)
    }
    
    public func valueOr(_ f: (E) -> A) -> A {
        return fold(f, id)
    }

    public func orElse(_ defaultValue: Validated<E, A>) -> Validated<E, A> {
        return fold(constant(defaultValue), Validated.valid)
    }
}

/// Safe downcast.
///
/// - Parameter fa: Value in higher-kind form.
/// - Returns: Value cast to Validated.
public postfix func ^<E, A>(_ fa: ValidatedOf<E, A>) -> Validated<E, A> {
    return Validated.fix(fa)
}

class Valid<E, A>: Validated<E, A> {
    fileprivate let value: A
    
    init(_ value: A) {
        self.value = value
    }
}

class Invalid<E, A>: Validated<E, A> {
    fileprivate let value: E
    
    init(_ value: E) {
        self.value = value
    }
}

extension Validated: CustomStringConvertible {
    public var description: String {
        return fold({ e in "Invalid(\(e))" },
                    { a in "Valid(\(a))" })
    }
}

extension Validated: CustomDebugStringConvertible where E : CustomDebugStringConvertible, A : CustomDebugStringConvertible {
    public var debugDescription: String {
        return fold({ error in "Invalid(\(error.debugDescription))" },
                    { value in "Valid(\(value.debugDescription))" })
    }
}

extension ValidatedPartial: EquatableK where I: Equatable {
    public static func eq<A>(_ lhs: Kind<ValidatedPartial<I>, A>, _ rhs: Kind<ValidatedPartial<I>, A>) -> Bool where A : Equatable {
        let vl = Validated.fix(lhs)
        let vr = Validated.fix(rhs)
        return vl.fold({ le in vr.fold({ re in le == re }, constant(false)) },
                       { la in vr.fold(constant(false), { ra in la == ra }) })
    }
}

extension ValidatedPartial: Functor {
    public static func map<A, B>(_ fa: Kind<ValidatedPartial<I>, A>, _ f: @escaping (A) -> B) -> Kind<ValidatedPartial<I>, B> {
        return Validated.fix(fa).fold(Validated.invalid, f >>> Validated.valid)
    }
}

extension ValidatedPartial: Applicative where I: Semigroup {
    public static func pure<A>(_ a: A) -> Kind<ValidatedPartial<I>, A> {
        return Validated.valid(a)
    }

    public static func ap<A, B>(_ ff: Kind<ValidatedPartial<I>, (A) -> B>, _ fa: Kind<ValidatedPartial<I>, A>) -> Kind<ValidatedPartial<I>, B> {
        let valA = Validated.fix(fa)
        let valF = Validated.fix(ff)
        return valA.fold({ e in valF.fold({ ee in Validated.invalid(e.combine(ee)) },
                                          { _ in Validated.invalid(e) }) },
                         { a in valF.fold({ ee in Validated.invalid(ee) },
                                          { f in Validated.valid(f(a)) }) })
    }
}

// MARK: Instance of `Selective` for `Validated`
extension ValidatedPartial: Selective where I: Semigroup {
    public static func select<A, B>(_ fab: Kind<ValidatedPartial<I>, Either<A, B>>, _ f: Kind<ValidatedPartial<I>, (A) -> B>) -> Kind<ValidatedPartial<I>, B> {
        return Validated.fix(fab).fold(
            { e in Validated.invalid(e) },
            { eab in eab.fold({ a in map(f, { ff in ff(a) }) },
                              { b in Validated.valid(b) })
            })
    }
}

extension ValidatedPartial: ApplicativeError where I: Semigroup {
    public typealias E = I

    public static func raiseError<A>(_ e: I) -> Kind<ValidatedPartial<I>, A> {
        return Validated.invalid(e)
    }

    public static func handleErrorWith<A>(_ fa: Kind<ValidatedPartial<I>, A>, _ f: @escaping (I) -> Kind<ValidatedPartial<I>, A>) -> Kind<ValidatedPartial<I>, A> {
        return Validated.fix(fa).fold(f, Validated.valid)
    }
}

extension ValidatedPartial: Foldable {
    public static func foldLeft<A, B>(_ fa: Kind<ValidatedPartial<I>, A>, _ b: B, _ f: @escaping (B, A) -> B) -> B {
        return Validated.fix(fa).fold(constant(b), { a in f(b, a) })
    }

    public static func foldRight<A, B>(_ fa: Kind<ValidatedPartial<I>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return Validated.fix(fa).fold(constant(b), { a in f(a, b) })
    }
}

extension ValidatedPartial: Traverse {
    public static func traverse<G: Applicative, A, B>(_ fa: Kind<ValidatedPartial<I>, A>, _ f: @escaping (A) -> Kind<G, B>) -> Kind<G, Kind<ValidatedPartial<I>, B>> {
        return Validated.fix(fa).fold(Validated.invalid >>> G.pure,
                                      { a in G.map(f(a), Validated.valid) })
    }
}

extension ValidatedPartial: SemigroupK where I: Semigroup {
    public static func combineK<A>(_ x: Kind<ValidatedPartial<I>, A>, _ y: Kind<ValidatedPartial<I>, A>) -> Kind<ValidatedPartial<I>, A> {
        return Validated.fix(x).fold({ e in
            Validated.fix(y).fold({ ee in Validated.invalid(e.combine(ee)) },
                   Validated.valid) }, Validated.valid)
    }
}
