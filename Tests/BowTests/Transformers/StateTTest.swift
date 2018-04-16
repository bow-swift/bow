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
        public typealias A = Kind3<ForStateT, ForId, Int, Int>
        
        public func eqv(_ a: Kind3<ForStateT, ForId, Int, Int>, _ b: Kind3<ForStateT, ForId, Int, Int>) -> Bool {
            let x = StateT.fix(a).runM(1, Id<Any>.monad()).fix().value
            let y = StateT.fix(b).runM(1, Id<Any>.monad()).fix().value
            return x == y
        }
    }
    
    class StateTIdUnitEq : Eq {
        public typealias A = Kind3<ForStateT, ForId, Int, ()>
        
        public func eqv(_ a: Kind3<ForStateT, ForId, Int, ()>, _ b: Kind3<ForStateT, ForId, Int, ()>) -> Bool {
            let x = StateT.fix(a).runM(1, Id<Any>.monad())
            let y = StateT.fix(b).runM(1, Id<Any>.monad())
            return Id.eq(Tuple.eq(Int.order, UnitEq())).eqv(x, y)
        }
    }
    
    class StateTUnitEq : Eq {
        public typealias A = Kind3<ForStateT, ForMaybe, (), Int>
        
        public func eqv(_ a: Kind3<ForStateT, ForMaybe, (), Int>, _ b: Kind3<ForStateT, ForMaybe, (), Int>) -> Bool {
            let x = StateT.fix(a).runM((), Maybe<Any>.monad())
            let y = StateT.fix(b).runM((), Maybe<Any>.monad())
            return Maybe.eq(Tuple.eq(UnitEq(), Int.order)).eqv(x, y)
        }
    }
    
    class StateTEitherEq : Eq {
        public typealias A = Kind3<ForStateT, ForMaybe, (), Kind2<ForEither, (), Int>>
        
        public func eqv(_ a: Kind3<ForStateT, ForMaybe, (), Kind2<ForEither, (), Int>>,
                        _ b: Kind3<ForStateT, ForMaybe, (), Kind2<ForEither, (), Int>>) -> Bool {
            let x = StateT.fix(a).runM((), Maybe<Any>.monad())
            let y = StateT.fix(b).runM((), Maybe<Any>.monad())
            return Maybe.eq(Tuple.eq(UnitEq(), Either.eq(UnitEq(), Int.order))).eqv(x, y)
        }
    }
    
    class StateTListKWEq : Eq {
        public typealias A = Kind3<ForStateT, ForListKW, Int, Int>
        
        public func eqv(_ a: Kind3<ForStateT, ForListKW, Int, Int>,
                        _ b: Kind3<ForStateT, ForListKW, Int, Int>) -> Bool {
            let x = StateT.fix(a).runM(1, ListKW<Any>.monad())
            let y = StateT.fix(b).runM(1, ListKW<Any>.monad())
            return ListKW.eq(Tuple.eq(Int.order, Int.order)).eqv(x, y)
        }
    }
    
    var generator : (Int) -> Kind3<ForStateT, ForId, Int, Int> {
        return { a in StateT.lift(Id<Int>.pure(a), Id<Any>.monad()) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<StateTPartial<ForId, Int>>.check(functor: StateT<ForId, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: StateTPointEq(), eqUnit: StateTIdUnitEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<StateTPartial<ForId, Int>>.check(applicative: StateT<ForId, Int, Int>.applicative(Id<Any>.monad()), eq: StateTPointEq())
    }
    
    func testMonadLaws() {
        MonadLaws<StateTPartial<ForId, Int>>.check(monad: StateT<ForId, Int, Int>.monad(Id<Any>.monad()), eq: StateTPointEq())
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<StateTPartial<ForMaybe, ()>, ()>.check(
            applicativeError: StateT<ForMaybe, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: StateTUnitEq(),
            eqEither: StateTEitherEq(),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<StateTPartial<ForMaybe, ()>, ()>.check(
            monadError: StateT<ForMaybe, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: StateTUnitEq(),
            gen: { () })
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<StateTPartial<ForListKW, Int>>.check(
            semigroupK: StateT<ForListKW, Int, Int>.semigroupK(ListKW<Int>.monad(), ListKW<Int>.semigroupK()),
            generator: { (a : Int) in StateT<ForListKW, Int, Int>.applicative(ListKW<Int>.monad()).pure(a) },
            eq: StateTListKWEq())
    }
    
    func testMonadStateLaws() {
        MonadStateLaws<StateTPartial<ForId, Int>>.check(
            monadState: StateT<ForId, Int, Int>.monadState(Id<Any>.monad()),
            eq: StateTPointEq(),
            eqUnit: StateTIdUnitEq())
    }
}
