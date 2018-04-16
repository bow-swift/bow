//
//  KleisliTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class KleisliTest: XCTestCase {
    
    class KleisliPointEq : Eq {
        typealias A = Kind3<KleisliKind, IdKind, Int, Int>
        
        func eqv(_ a: Kind<Kind<Kind<KleisliKind, IdKind>, Int>, Int>, _ b: Kind<Kind<Kind<KleisliKind, IdKind>, Int>, Int>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return a.invoke(1).fix().value == b.invoke(1).fix().value
        }
    }
    
    class KleisliUnitEq : Eq {
        typealias A = Kind3<KleisliKind, MaybeKind, (), Int>
        
        func eqv(_ a: Kind<Kind<Kind<KleisliKind, MaybeKind>, ()>, Int>, _ b: Kind<Kind<Kind<KleisliKind, MaybeKind>, ()>, Int>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return Maybe.eq(Int.order).eqv(a.invoke(()),
                                           b.invoke(()))
        }
    }
    
    class KleisliIntUnitEq : Eq {
        typealias A = Kind3<KleisliKind, IdKind, Int, ()>
        
        func eqv(_ a: Kind<Kind<Kind<KleisliKind, IdKind>, Int>, ()>, _ b: Kind<Kind<Kind<KleisliKind, IdKind>, Int>, ()>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return Id.eq(UnitEq()).eqv(a.invoke(1),
                                       b.invoke(1))
        }
    }
    
    class KleisliEitherEq : Eq {
        typealias A = Kind3<KleisliKind, MaybeKind, (), Kind2<EitherKind, (), Int>>
        
        func eqv(_ a: Kind<Kind<Kind<KleisliKind, MaybeKind>, ()>, Kind2<EitherKind, (), Int>>,
                 _ b: Kind<Kind<Kind<KleisliKind, MaybeKind>, ()>, Kind2<EitherKind, (), Int>>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return Maybe.eq(Either.eq(UnitEq(), Int.order)).eqv(a.invoke(()),
                                                                b.invoke(()))
        }
    }
    
    var generator : (Int) -> Kind3<KleisliKind, IdKind, Int, Int> {
        return { a in Kleisli.pure(a, Id<Int>.applicative()) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<KleisliPartial<IdKind, Int>>.check(functor: Kleisli<IdKind, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: KleisliPointEq(), eqUnit: KleisliIntUnitEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<KleisliPartial<IdKind, Int>>.check(applicative: Kleisli<IdKind, Int, Int>.applicative(Id<Any>.applicative()), eq: KleisliPointEq())
    }
    
    func testMonadLaws() {
        MonadLaws<KleisliPartial<IdKind, Int>>.check(monad: Kleisli<IdKind, Int, Int>.monad(Id<Any>.monad()), eq: KleisliPointEq())
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<KleisliPartial<MaybeKind, ()>, ()>.check(
            applicativeError: Kleisli<MaybeKind, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: KleisliUnitEq(),
            eqEither: KleisliEitherEq(),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<KleisliPartial<MaybeKind, ()>, ()>.check(
            monadError: Kleisli<MaybeKind, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: KleisliUnitEq(),
            gen: { ()})
    }
}
