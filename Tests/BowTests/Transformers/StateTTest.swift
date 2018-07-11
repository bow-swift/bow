import XCTest
@testable import Bow

class StateTTest: XCTestCase {
    
    class StateTPointEq : Eq {
        public typealias A = StateTOf<ForId, Int, Int>
        
        public func eqv(_ a: StateTOf<ForId, Int, Int>, _ b: StateTOf<ForId, Int, Int>) -> Bool {
            let x = StateT.fix(a).runM(1, Id<Any>.monad()).fix().value
            let y = StateT.fix(b).runM(1, Id<Any>.monad()).fix().value
            return x == y
        }
    }
    
    class StateTIdUnitEq : Eq {
        public typealias A = StateTOf<ForId, Int, ()>
        
        public func eqv(_ a: StateTOf<ForId, Int, ()>, _ b: StateTOf<ForId, Int, ()>) -> Bool {
            let x = StateT.fix(a).runM(1, Id<Any>.monad())
            let y = StateT.fix(b).runM(1, Id<Any>.monad())
            return Id.eq(Tuple.eq(Int.order, UnitEq())).eqv(x, y)
        }
    }
    
    class StateTUnitEq : Eq {
        public typealias A = StateTOf<ForMaybe, (), Int>
        
        public func eqv(_ a: StateTOf<ForMaybe, (), Int>, _ b: StateTOf<ForMaybe, (), Int>) -> Bool {
            let x = StateT.fix(a).runM((), Maybe<Any>.monad())
            let y = StateT.fix(b).runM((), Maybe<Any>.monad())
            return Maybe.eq(Tuple.eq(UnitEq(), Int.order)).eqv(x, y)
        }
    }
    
    class StateTEitherEq : Eq {
        public typealias A = StateTOf<ForMaybe, (), EitherOf<(), Int>>
        
        public func eqv(_ a: StateTOf<ForMaybe, (), EitherOf<(), Int>>,
                        _ b: StateTOf<ForMaybe, (), EitherOf<(), Int>>) -> Bool {
            let x = StateT.fix(a).runM((), Maybe<Any>.monad())
            let y = StateT.fix(b).runM((), Maybe<Any>.monad())
            return Maybe.eq(Tuple.eq(UnitEq(), Either.eq(UnitEq(), Int.order))).eqv(x, y)
        }
    }
    
    class StateTListKEq : Eq {
        public typealias A = StateTOf<ForListK, Int, Int>
        
        public func eqv(_ a: StateTOf<ForListK, Int, Int>,
                        _ b: StateTOf<ForListK, Int, Int>) -> Bool {
            let x = StateT.fix(a).runM(1, ListK<Any>.monad())
            let y = StateT.fix(b).runM(1, ListK<Any>.monad())
            return ListK.eq(Tuple.eq(Int.order, Int.order)).eqv(x, y)
        }
    }
    
    var generator : (Int) -> StateTOf<ForId, Int, Int> {
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
        SemigroupKLaws<StateTPartial<ForListK, Int>>.check(
            semigroupK: StateT<ForListK, Int, Int>.semigroupK(ListK<Int>.monad(), ListK<Int>.semigroupK()),
            generator: { (a : Int) in StateT<ForListK, Int, Int>.applicative(ListK<Int>.monad()).pure(a) },
            eq: StateTListKEq())
    }
    
    func testMonadStateLaws() {
        MonadStateLaws<StateTPartial<ForId, Int>>.check(
            monadState: StateT<ForId, Int, Int>.monadState(Id<Any>.monad()),
            eq: StateTPointEq(),
            eqUnit: StateTIdUnitEq())
    }
    
    func testMonadCombineLaws() {
        MonadCombineLaws<StateTPartial<ForListK, Int>>.check(monadCombine: StateT<ForListK, Int, Int>.monadCombine(ListK<Int>.monadCombine()), eq: StateTListKEq())
    }
}
