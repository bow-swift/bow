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
        typealias A = Kind3<KleisliF, IdF, Int, Int>
        
        func eqv(_ a: Kind<Kind<Kind<KleisliF, IdF>, Int>, Int>, _ b: Kind<Kind<Kind<KleisliF, IdF>, Int>, Int>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return a.invoke(1).fix().value == b.invoke(1).fix().value
        }
    }
    
    class KleisliUnitEq : Eq {
        typealias A = Kind3<KleisliF, MaybeF, (), Int>
        
        func eqv(_ a: Kind<Kind<Kind<KleisliF, MaybeF>, ()>, Int>, _ b: Kind<Kind<Kind<KleisliF, MaybeF>, ()>, Int>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return Maybe.eq(Int.order).eqv(a.invoke(()),
                                           b.invoke(()))
        }
    }
    
    class KleisliIntUnitEq : Eq {
        typealias A = Kind3<KleisliF, IdF, Int, ()>
        
        func eqv(_ a: Kind<Kind<Kind<KleisliF, IdF>, Int>, ()>, _ b: Kind<Kind<Kind<KleisliF, IdF>, Int>, ()>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return Id.eq(UnitEq()).eqv(a.invoke(1),
                                       b.invoke(1))
        }
    }
    
    class KleisliEitherEq : Eq {
        typealias A = HK3<KleisliF, MaybeF, (), Kind2<EitherF, (), Int>>
        
        func eqv(_ a: Kind<Kind<Kind<KleisliF, MaybeF>, ()>, HK2<EitherF, (), Int>>,
                 _ b: Kind<Kind<Kind<KleisliF, MaybeF>, ()>, HK2<EitherF, (), Int>>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return Maybe.eq(Either.eq(UnitEq(), Int.order)).eqv(a.invoke(()),
                                                                b.invoke(()))
        }
    }
    
    var generator : (Int) -> Kind3<KleisliF, IdF, Int, Int> {
        return { a in Kleisli.pure(a, Id<Int>.applicative()) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<KleisliPartial<IdF, Int>>.check(functor: Kleisli<IdF, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: KleisliPointEq(), eqUnit: KleisliIntUnitEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<KleisliPartial<IdF, Int>>.check(applicative: Kleisli<IdF, Int, Int>.applicative(Id<Any>.applicative()), eq: KleisliPointEq())
    }
    
    func testMonadLaws() {
        MonadLaws<KleisliPartial<IdF, Int>>.check(monad: Kleisli<IdF, Int, Int>.monad(Id<Any>.monad()), eq: KleisliPointEq())
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<KleisliPartial<MaybeF, ()>, ()>.check(
            applicativeError: Kleisli<MaybeF, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: KleisliUnitEq(),
            eqEither: KleisliEitherEq(),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<KleisliPartial<MaybeF, ()>, ()>.check(
            monadError: Kleisli<MaybeF, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: KleisliUnitEq(),
            gen: { ()})
    }
}
