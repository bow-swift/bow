//
//  Validated.swift
//  CategoryCore
//
//  Created by Tomás Ruiz López on 4/10/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import Foundation

public class ValidatedF {}
public typealias ValidatedPartial<E> = HK<ValidatedF, E>

public class Validated<E, A> : HK2<ValidatedF, E, A> {
    public static func valid(_ value : A) -> Validated<E, A> {
        return Valid(value)
    }
    
    public static func invalid(_ value : E) -> Validated<E, A> {
        return Invalid(value)
    }
    
    public static func fromTry(_ t : Try<A>) -> Validated<Error, A> {
        return t.fold(Validated<Error, A>.invalid, Validated<Error, A>.valid)
    }
    
    public static func fromEither(_ e : Either<E, A>) -> Validated<E, A> {
        return e.fold(Validated<E, A>.invalid, Validated<E, A>.valid)
    }
    
    public static func fromMaybe(_ m : Maybe<A>, ifNone : @escaping () -> E) -> Validated<E, A> {
        return m.fold(ifNone >> Validated<E, A>.invalid, Validated<E, A>.valid)
    }
    
    public func fold<C>(_ fe : (E) -> C, _ fa : (A) -> C) -> C {
        switch(self) {
            case is Invalid<E, A>:
                return fe((self as! Invalid).value)
            case is Valid<E, A>:
                return fa((self as! Valid).value)
            default:
                fatalError("Validated must only have Valid and Invalid cases")
        }
    }
    
    public var isValid : Bool {
        return fold(constF(false), constF(true))
    }
    
    public var isInvalid : Bool {
        return !isValid
    }
    
    public func exists(_ predicate : (A) -> Bool) -> Bool {
        return fold(constF(false), predicate)
    }
    
    public func toEither() -> Either<E, A> {
        return fold(Either.left, Either.right)
    }
    
    public func toMaybe() -> Maybe<A> {
        return fold(constF(Maybe.none()), Maybe.some)
    }
    
    public func toList() -> [A] {
        return fold(constF([]), { a in [a] })
    }
    
    public func withEither<EE, B>(_ f : (Either<E, A>) -> Either<EE, B>) -> Validated<EE, B> {
        return Validated<EE, B>.fromEither(f(self.toEither()))
    }
    
    public func bimap<EE, AA>(_ fe : @escaping (E) -> EE, _ fa : @escaping (A) -> AA) -> Validated<EE, AA> {
        return fold(fe >> Validated<EE, AA>.invalid,
                    fa >> Validated<EE, AA>.valid)
    }
    
    public func map<B>(_ f : @escaping (A) -> B) -> Validated<E, B> {
        return bimap(id, f)
    }
    
    public func leftMap<EE>(_ f : @escaping (E) -> EE) -> Validated<EE, A> {
        return bimap(f, id)
    }
    
    public func ap<B, SemiG>(_ ff : Validated<E, (A) -> B>, _ semigroup : SemiG) -> Validated<E, B> where SemiG : Semigroup, SemiG.A == E {
        return fold({ e in ff.fold({ ee in Validated<E, B>.invalid(semigroup.combine(e, ee)) },
                                   { _ in Validated<E, B>.invalid(e) }) },
                    { a in ff.fold({ ee in Validated<E, B>.invalid(ee) },
                                   { f in Validated<E, B>.valid(f(a)) }) })
    }
    
    public func foldL<B>(_ b : B, _ f : (B, A) -> B) -> B {
        return fold(constF(b), { a in f(b, a) })
    }
    
    public func foldR<B>(_ b : Eval<B>, _ f : (A, Eval<B>) -> Eval<B>) -> Eval<B>{
        return fold(constF(b), { a in f(a, b) })
    }
    
    public func swap() -> Validated<A, E> {
        return fold(Validated<A, E>.valid, Validated<A, E>.invalid)
    }
    
    public func getOrElse(_ defaultValue : A) -> A {
        return fold(constF(defaultValue), id)
    }
    
    public func valueOr(_ f : (E) -> A) -> A {
        return fold(f, id)
    }
    
    public func findValid<SemiG>(_ semigroup : SemiG, _ other : Validated<E, A>) -> Validated<E, A> where SemiG : Semigroup, SemiG.A == E {
        return fold({ e in other.fold({ ee in Validated.invalid(semigroup.combine(e, ee))},
                                      Validated.valid)},
                    Validated.valid)
    }
    
    public func orElse(_ defaultValue : Validated<E, A>) -> Validated<E, A> {
        return fold(constF(defaultValue), Validated.valid)
    }
    
    public func handleLeftWith(_ f : (E) -> Validated<E, A>) -> Validated<E, A> {
        return fold(f, Validated.valid)
    }
    
    public func traverse<G, B, Appl>(_ f : (A) -> HK<G, B>, _ applicative : Appl) -> HK<G, HK2<ValidatedF, E, B>> where Appl : Applicative, Appl.F == G {
        return fold(Validated<E, B>.invalid >> applicative.pure,
                    { a in applicative.map(f(a), Validated<E, B>.valid) })
    }
    
    public func combineK<SemiG>(_ y : Validated<E, A>, _ semigroup : SemiG) -> Validated<E, A> where SemiG : Semigroup, SemiG.A == E {
        return fold({ e in y.fold({ ee in Validated.invalid(semigroup.combine(e, ee))},
                                  Validated.valid) },
                    Validated.valid)
    }
}

class Valid<E, A> : Validated<E, A> {
    fileprivate let value : A
    
    init(_ value : A) {
        self.value = value
    }
}

class Invalid<E, A> : Validated<E, A> {
    fileprivate let value : E
    
    init(_ value : E) {
        self.value = value
    }
}

extension Validated : CustomStringConvertible {
    public var description : String {
        return fold({ e in "Invalid(\(e))" },
                    { a in "Valid(\(a)" })
    }
}

public extension Validated {
    public static func functor() -> ValidatedFunctor<E> {
        return ValidatedFunctor<E>()
    }
    
    public static func applicative<SemiG>(_ semigroup : SemiG) -> ValidatedApplicative<E, SemiG> {
        return ValidatedApplicative<E, SemiG>(semigroup)
    }
    
    public static func applicativeError<SemiG>(_ semigroup : SemiG) -> ValidatedApplicativeError<E, SemiG> {
        return ValidatedApplicativeError<E, SemiG>(semigroup)
    }
    
    public static func foldable() -> ValidatedFoldable<E> {
        return ValidatedFoldable<E>()
    }
    
    public static func traverse() -> ValidatedTraverse<E> {
        return ValidatedTraverse<E>()
    }
    
    public static func semigroupK<SemiG>(_ semigroup : SemiG) -> ValidatedSemigroupK<E, SemiG> {
        return ValidatedSemigroupK<E, SemiG>(semigroup)
    }
    
    public static func eq<EqE, EqA>(_ eqe : EqE, _ eqa : EqA) -> ValidatedEq<E, A, EqE, EqA> {
        return ValidatedEq<E, A, EqE, EqA>(eqe, eqa)
    }
}

public class ValidatedFunctor<R> : Functor {
    public typealias F = ValidatedPartial<R>
    
    public func map<A, B>(_ fa: HK<HK<ValidatedF, R>, A>, _ f: @escaping (A) -> B) -> HK<HK<ValidatedF, R>, B> {
        return (fa as! Validated<R, A>).map(f)
    }
}

public class ValidatedApplicative<R, SemiG> : ValidatedFunctor<R>, Applicative where SemiG : Semigroup, SemiG.A == R {
    private let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func pure<A>(_ a: A) -> HK<HK<ValidatedF, R>, A> {
        return Validated<R, A>.valid(a)
    }
    
    public func ap<A, B>(_ fa: HK<HK<ValidatedF, R>, A>, _ ff: HK<HK<ValidatedF, R>, (A) -> B>) -> HK<HK<ValidatedF, R>, B> {
        return (fa as! Validated<R, A>).ap(ff as! Validated<R, (A) -> B>, semigroup)
    }
}

public class ValidatedApplicativeError<R, SemiG> : ValidatedApplicative<R, SemiG>, ApplicativeError where SemiG : Semigroup, SemiG.A == R {
    public typealias E = R
    
    public func raiseError<A>(_ e: R) -> HK<HK<ValidatedF, R>, A> {
        return Validated<R, A>.invalid(e)
    }
    
    public func handleErrorWith<A>(_ fa: HK<HK<ValidatedF, R>, A>, _ f: (R) -> HK<HK<ValidatedF, R>, A>) -> HK<HK<ValidatedF, R>, A> {
        return (fa as! Validated<R, A>).handleLeftWith({ r in f(r) as! Validated<R, A> })
    }
}

public class ValidatedFoldable<R> : Foldable {
    public typealias F = ValidatedPartial<R>
    
    public func foldL<A, B>(_ fa: HK<HK<ValidatedF, R>, A>, _ b: B, _ f: (B, A) -> B) -> B {
        return (fa as! Validated<R, A>).foldL(b, f)
    }
    
    public func foldR<A, B>(_ fa: HK<HK<ValidatedF, R>, A>, _ b: Eval<B>, _ f: @escaping (A, Eval<B>) -> Eval<B>) -> Eval<B> {
        return (fa as! Validated<R, A>).foldR(b, f)
    }
}

public class ValidatedTraverse<R> : ValidatedFoldable<R>, Traverse {
    public func traverse<G, A, B, Appl>(_ fa: HK<HK<ValidatedF, R>, A>, _ f: @escaping (A) -> HK<G, B>, _ applicative: Appl) -> HK<G, HK<HK<ValidatedF, R>, B>> where G == Appl.F, Appl : Applicative {
        return (fa as! Validated<R, A>).traverse(f, applicative)
    }
}

public class ValidatedSemigroupK<R, SemiG> : SemigroupK where SemiG : Semigroup, SemiG.A == R {
    public typealias F = ValidatedPartial<R>
    
    private let semigroup : SemiG
    
    public init(_ semigroup : SemiG) {
        self.semigroup = semigroup
    }
    
    public func combineK<A>(_ x: HK<HK<ValidatedF, R>, A>, _ y: HK<HK<ValidatedF, R>, A>) -> HK<HK<ValidatedF, R>, A> {
        return (x as! Validated<R, A>).combineK(y as! Validated<R, A>, semigroup)
    }
}

public class ValidatedEq<L, R, EqL, EqR> : Eq where EqL : Eq, EqL.A == L, EqR : Eq, EqR.A == R {
    public typealias A = Validated<L, R>
    private let eql : EqL
    private let eqr : EqR
    
    public init(_ eql : EqL, _ eqr : EqR) {
        self.eql = eql
        self.eqr = eqr
    }
    
    public func eqv(_ a: Validated<L, R>, _ b: Validated<L, R>) -> Bool {
        return a.fold({ aInvalid in b.fold({ bInvalid in eql.eqv(aInvalid, bInvalid)}, constF(false))},
                      { aValid in b.fold(constF(false), { bValid in eqr.eqv(aValid, bValid) })})
    }
}
