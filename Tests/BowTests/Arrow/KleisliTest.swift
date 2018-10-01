import XCTest
@testable import Bow

class KleisliTest: XCTestCase {
    
    class KleisliPointEq : Eq {
        typealias A = KleisliOf<ForId, Int, Int>
        
        func eqv(_ a: KleisliOf<ForId, Int, Int>, _ b: KleisliOf<ForId, Int, Int>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return a.invoke(1).fix().value == b.invoke(1).fix().value
        }
    }
    
    class KleisliUnitEq : Eq {
        typealias A = KleisliOf<ForOption, (), Int>
        
        func eqv(_ a: KleisliOf<ForOption, (), Int>, _ b: KleisliOf<ForOption, (), Int>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return Option.eq(Int.order).eqv(a.invoke(()),
                                           b.invoke(()))
        }
    }
    
    class KleisliIntUnitEq : Eq {
        typealias A = KleisliOf<ForId, Int, ()>
        
        func eqv(_ a: KleisliOf<ForId, Int, ()>, _ b: KleisliOf<ForId, Int, ()>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return Id.eq(UnitEq()).eqv(a.invoke(1),
                                       b.invoke(1))
        }
    }
    
    class KleisliEitherEq : Eq {
        typealias A = KleisliOf<ForOption, (), EitherOf<(), Int>>
        
        func eqv(_ a: KleisliOf<ForOption, (), EitherOf<(), Int>>,
                 _ b: KleisliOf<ForOption, (), EitherOf<(), Int>>) -> Bool {
            let a = Kleisli.fix(a)
            let b = Kleisli.fix(b)
            return Option.eq(Either.eq(UnitEq(), Int.order)).eqv(a.invoke(()),
                                                                b.invoke(()))
        }
    }
    
    var generator : (Int) -> KleisliOf<ForId, Int, Int> {
        return { a in Kleisli.pure(a, Id<Int>.applicative()) }
    }
    
    func testFunctorLaws() {
        FunctorLaws<KleisliPartial<ForId, Int>>.check(functor: Kleisli<ForId, Int, Int>.functor(Id<Any>.functor()), generator: self.generator, eq: KleisliPointEq(), eqUnit: KleisliIntUnitEq())
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<KleisliPartial<ForId, Int>>.check(applicative: Kleisli<ForId, Int, Int>.applicative(Id<Any>.applicative()), eq: KleisliPointEq())
    }
    
    func testMonadLaws() {
        MonadLaws<KleisliPartial<ForId, Int>>.check(monad: Kleisli<ForId, Int, Int>.monad(Id<Any>.monad()), eq: KleisliPointEq())
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<KleisliPartial<ForOption, ()>, ()>.check(
            applicativeError: Kleisli<ForOption, (), Int>.monadError(Option<Any>.monadError()),
            eq: KleisliUnitEq(),
            eqEither: KleisliEitherEq(),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<KleisliPartial<ForOption, ()>, ()>.check(
            monadError: Kleisli<ForOption, (), Int>.monadError(Option<Any>.monadError()),
            eq: KleisliUnitEq(),
            gen: { ()})
    }
}
