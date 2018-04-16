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
        public typealias A = Kind3<StateTKind, IdKind, Int, Int>
        
        public func eqv(_ a: Kind3<StateTKind, IdKind, Int, Int>, _ b: Kind3<StateTKind, IdKind, Int, Int>) -> Bool {
            let x = StateT.fix(a).runM(1, Id<Any>.monad()).fix().value
            let y = StateT.fix(b).runM(1, Id<Any>.monad()).fix().value
            return x == y
        }
    }
    
    class StateTIdUnitEq : Eq {
        public typealias A = Kind3<StateTKind, IdKind, Int, ()>
        
        public func eqv(_ a: Kind3<StateTKind, IdKind, Int, ()>, _ b: Kind3<StateTKind, IdKind, Int, ()>) -> Bool {
            let x = StateT.fix(a).runM(1, Id<Any>.monad())
            let y = StateT.fix(b).runM(1, Id<Any>.monad())
            return Id.eq(Tuple.eq(Int.order, UnitEq())).eqv(x, y)
        }
    }
    
    class StateTUnitEq : Eq {
        public typealias A = Kind3<StateTKind, MaybeKind, (), Int>
        
        public func eqv(_ a: Kind3<StateTKind, MaybeKind, (), Int>, _ b: Kind3<StateTKind, MaybeKind, (), Int>) -> Bool {
            let x = StateT.fix(a).runM((), Maybe<Any>.monad())
            let y = StateT.fix(b).runM((), Maybe<Any>.monad())
            return Maybe.eq(Tuple.eq(UnitEq(), Int.order)).eqv(x, y)
        }
    }
    
    class StateTEitherEq : Eq {
        public typealias A = Kind3<StateTKind, MaybeKind, (), Kind2<EitherKind, (), Int>>
        
        public func eqv(_ a: Kind3<StateTKind, MaybeKind, (), Kind2<EitherKind, (), Int>>,
                        _ b: Kind3<StateTKind, MaybeKind, (), Kind2<EitherKind, (), Int>>) -> Bool {
            let x = StateT.fix(a).runM((), Maybe<Any>.monad())
            let y = StateT.fix(b).runM((), Maybe<Any>.monad())
            return Maybe.eq(Tuple.eq(UnitEq(), Either.eq(UnitEq(), Int.order))).eqv(x, y)
        }
    }
    
    class StateTListKWEq : Eq {
        public typealias A = Kind3<StateTKind, ListKWKind, Int, Int>
        
        public func eqv(_ a: Kind3<StateTKind, ListKWKind, Int, Int>,
                        _ b: Kind3<StateTKind, ListKWKind, Int, Int>) -> Bool {
            let x = StateT.fix(a).runM(1, ListKW<Any>.monad())
            let y = StateT.fix(b).runM(1, ListKW<Any>.monad())
            return ListKW.eq(Tuple.eq(Int.order, Int.order)).eqv(x, y)
        }
    }
    
    var generator : (Int) -> Kind3<StateTKind, IdKind, Int, Int> {
        return { a in StateT.lift(Id<Int>.pure(a), Id<Any>.monad()) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<StateTPartial<IdKind, Int>>.check(functor: StateT<IdKind, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: StateTPointEq(), eqUnit: StateTIdUnitEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<StateTPartial<IdKind, Int>>.check(applicative: StateT<IdKind, Int, Int>.applicative(Id<Any>.monad()), eq: StateTPointEq())
    }
    
    func testMonadLaws() {
        MonadLaws<StateTPartial<IdKind, Int>>.check(monad: StateT<IdKind, Int, Int>.monad(Id<Any>.monad()), eq: StateTPointEq())
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<StateTPartial<MaybeKind, ()>, ()>.check(
            applicativeError: StateT<MaybeKind, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: StateTUnitEq(),
            eqEither: StateTEitherEq(),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<StateTPartial<MaybeKind, ()>, ()>.check(
            monadError: StateT<MaybeKind, (), Int>.monadError(Maybe<Any>.monadError()),
            eq: StateTUnitEq(),
            gen: { () })
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<StateTPartial<ListKWKind, Int>>.check(
            semigroupK: StateT<ListKWKind, Int, Int>.semigroupK(ListKW<Int>.monad(), ListKW<Int>.semigroupK()),
            generator: { (a : Int) in StateT<ListKWKind, Int, Int>.applicative(ListKW<Int>.monad()).pure(a) },
            eq: StateTListKWEq())
    }
    
    func testMonadStateLaws() {
        MonadStateLaws<StateTPartial<IdKind, Int>>.check(
            monadState: StateT<IdKind, Int, Int>.monadState(Id<Any>.monad()),
            eq: StateTPointEq(),
            eqUnit: StateTIdUnitEq())
    }
}
