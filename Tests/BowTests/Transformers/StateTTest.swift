//
//  StateTTest.swift
//  BowTests
//
//  Created by Tomás Ruiz López on 21/11/17.
//  Copyright © 2017 Tomás Ruiz López. All rights reserved.
//

import XCTest
@testable import Bow

class StateTTest: XCTestCase {
    
    class StateTPointEq : Eq {
        public typealias A = HK3<StateTF, IdF, Int, Int>
        
        public func eqv(_ a: HK3<StateTF, IdF, Int, Int>, _ b: HK3<StateTF, IdF, Int, Int>) -> Bool {
            let x = StateT.ev(a).runM(1, Id<Any>.monad()).fix().value
            let y = StateT.ev(b).runM(1, Id<Any>.monad()).fix().value
            return x == y
        }
    }
    
    class StateTIdUnitEq : Eq {
        public typealias A = HK3<StateTF, IdF, Int, ()>
        
        public func eqv(_ a: HK3<StateTF, IdF, Int, ()>, _ b: HK3<StateTF, IdF, Int, ()>) -> Bool {
            let x = StateT.ev(a).runM(1, Id<Any>.monad())
            let y = StateT.ev(b).runM(1, Id<Any>.monad())
            return Id.eq(Tuple.eq(Int.order, UnitEq())).eqv(x, y)
        }
    }
    
    class StateTUnitEq : Eq {
        public typealias A = HK3<StateTF, MaybeF, (), Int>
        
        public func eqv(_ a: HK3<StateTF, MaybeF, (), Int>, _ b: HK3<StateTF, MaybeF, (), Int>) -> Bool {
            let x = StateT.ev(a).runM((), Maybe<Any>.monad())
            let y = StateT.ev(b).runM((), Maybe<Any>.monad())
            return Maybe.eq(Tuple.eq(UnitEq(), Int.order)).eqv(x, y)
        }
    }
    
    class StateTEitherEq : Eq {
        public typealias A = HK3<StateTF, MaybeF, (), HK2<EitherF, (), Int>>
        
        public func eqv(_ a: HK3<StateTF, MaybeF, (), HK2<EitherF, (), Int>>,
                        _ b: HK3<StateTF, MaybeF, (), HK2<EitherF, (), Int>>) -> Bool {
            let x = StateT.ev(a).runM((), Maybe<Any>.monad())
            let y = StateT.ev(b).runM((), Maybe<Any>.monad())
            return Maybe.eq(Tuple.eq(UnitEq(), Either.eq(UnitEq(), Int.order))).eqv(x, y)
        }
    }
    
    class StateTListKWEq : Eq {
        public typealias A = HK3<StateTF, ListKWF, Int, Int>
        
        public func eqv(_ a: HK3<StateTF, ListKWF, Int, Int>,
                        _ b: HK3<StateTF, ListKWF, Int, Int>) -> Bool {
            let x = StateT.ev(a).runM(1, ListKW<Any>.monad())
            let y = StateT.ev(b).runM(1, ListKW<Any>.monad())
            return ListKW.eq(Tuple.eq(Int.order, Int.order)).eqv(x, y)
        }
    }
    
    var generator : (Int) -> HK3<StateTF, IdF, Int, Int> {
        return { a in StateT.lift(Id<Int>.pure(a), Id<Any>.monad()) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<StateTPartial<IdF, Int>>.check(functor: StateT<IdF, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: StateTPointEq(), eqUnit: StateTIdUnitEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<StateTPartial<IdF, Int>>.check(applicative: StateT<IdF, Int, Int>.applicative(Id<Any>.monad()), eq: StateTPointEq())
    }
    
    func testMonadLaws() {
        MonadLaws<StateTPartial<IdF, Int>>.check(monad: StateT<IdF, Int, Int>.monad(Id<Any>.monad()), eq: StateTPointEq())
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<StateTPartial<MaybeF, ()>, ()>.check(
            applicativeError: StateT<MaybeF, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: StateTUnitEq(),
            eqEither: StateTEitherEq(),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<StateTPartial<MaybeF, ()>, ()>.check(
            monadError: StateT<MaybeF, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: StateTUnitEq(),
            gen: { () })
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<StateTPartial<ListKWF, Int>>.check(
            semigroupK: StateT<ListKWF, Int, Int>.semigroupK(ListKW<Int>.monad(), ListKW<Int>.semigroupK()),
            generator: { (a : Int) in StateT<ListKWF, Int, Int>.applicative(ListKW<Int>.monad()).pure(a) },
            eq: StateTListKWEq())
    }
    
    func testMonadStateLaws() {
        MonadStateLaws<StateTPartial<IdF, Int>>.check(
            monadState: StateT<IdF, Int, Int>.monadState(Id<Any>.monad()),
            eq: StateTPointEq(),
            eqUnit: StateTIdUnitEq())
    }
}
