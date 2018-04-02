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
        typealias A = HK3<KleisliF, IdF, Int, Int>
        
        func eqv(_ a: HK<HK<HK<KleisliF, IdF>, Int>, Int>, _ b: HK<HK<HK<KleisliF, IdF>, Int>, Int>) -> Bool {
            let a = Kleisli.ev(a)
            let b = Kleisli.ev(b)
            return a.invoke(1).ev().value == b.invoke(1).ev().value
        }
    }
    
    class KleisliUnitEq : Eq {
        typealias A = HK3<KleisliF, MaybeF, (), Int>
        
        func eqv(_ a: HK<HK<HK<KleisliF, MaybeF>, ()>, Int>, _ b: HK<HK<HK<KleisliF, MaybeF>, ()>, Int>) -> Bool {
            let a = Kleisli.ev(a)
            let b = Kleisli.ev(b)
            return Maybe.eq(Int.order).eqv(a.invoke(()),
                                           b.invoke(()))
        }
    }
    
    class KleisliIntUnitEq : Eq {
        typealias A = HK3<KleisliF, IdF, Int, ()>
        
        func eqv(_ a: HK<HK<HK<KleisliF, IdF>, Int>, ()>, _ b: HK<HK<HK<KleisliF, IdF>, Int>, ()>) -> Bool {
            let a = Kleisli.ev(a)
            let b = Kleisli.ev(b)
            return Id.eq(UnitEq()).eqv(a.invoke(1),
                                       b.invoke(1))
        }
    }
    
    class KleisliEitherEq : Eq {
        typealias A = HK3<KleisliF, MaybeF, (), HK2<EitherF, (), Int>>
        
        func eqv(_ a: HK<HK<HK<KleisliF, MaybeF>, ()>, HK2<EitherF, (), Int>>,
                 _ b: HK<HK<HK<KleisliF, MaybeF>, ()>, HK2<EitherF, (), Int>>) -> Bool {
            let a = Kleisli.ev(a)
            let b = Kleisli.ev(b)
            return Maybe.eq(Either.eq(UnitEq(), Int.order)).eqv(a.invoke(()),
                                                                b.invoke(()))
        }
    }
    
    var generator : (Int) -> HK3<KleisliF, IdF, Int, Int> {
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
