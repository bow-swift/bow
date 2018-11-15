import XCTest
import SwiftCheck
@testable import BowLaws
@testable import Bow

class EitherTTest: XCTestCase {
    var generator : (Int) -> EitherT<ForId, Int, Int> {
        return { a in a % 2 == 0 ? EitherT.pure(a, Id<Int>.applicative())
                                 : EitherT.left(a, Id<Int>.applicative())
        }
    }
    
    let eq = EitherT.eq(Id.eq(Either.eq(Int.order, Int.order)), Id<Any>.functor())
    let eqUnit = EitherT.eq(Id.eq(Either.eq(Int.order, UnitEq())), Id<Any>.functor())
    
    func testEqLaws() {
        EqLaws.check(eq: self.eq, generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<EitherTPartial<ForId, Int>>.check(
            functor: EitherT<ForId, Int, Int>.functor(Id<Any>.functor()),
            generator: self.generator,
            eq: self.eq,
            eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<EitherTPartial<ForId, Int>>.check(applicative: EitherT<ForId, Int, Int>.applicative(Id<Any>.monad()), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<EitherTPartial<ForId, Int>>.check(monad: EitherT<ForId, Int, Int>.monad(Id<Any>.monad()), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<EitherTPartial<ForOption, ()>, ()>.check(
            applicativeError: EitherT<ForOption, (), Int>.monadError(Option<Int>.monadError()),
            eq: EitherT<ForOption, (), Int>.eq(Option.eq(Either.eq(UnitEq(), Int.order)), Option<Int>.functor()),
            eqEither: EitherT.eq(Option.eq(Either.eq(UnitEq(), Either.eq(UnitEq(), Int.order))), Option<Any>.functor()),
            gen: { () })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<EitherTPartial<ForOption, ()>, ()>.check(
            monadError: EitherT<ForOption, (), Int>.monadError(Option<Int>.monadError()),
            eq: EitherT<ForOption, (), Int>.eq(Option.eq(Either.eq(UnitEq(), Int.order)), Option<Int>.functor()),
            gen: { () })
    }
    
    func testSemigroupKLaws() {
        SemigroupKLaws<EitherTPartial<ForId, Int>>.check(semigroupK: EitherT<ForId, Int, Int>.semigroupK(Id<Any>.monad()), generator: self.generator, eq: self.eq)
    }
    
    func testSemigroupLaws() {
        property("Semigroup laws") <- forAll { (a : Int, b : Int, c : Int) in
            return SemigroupLaws.check(semigroup: EitherT<ForId, Int, Int>.semigroupK(Id<Any>.monad()).algebra(),
                                       a: self.generator(a),
                                       b: self.generator(b),
                                       c: self.generator(c),
                                       eq: self.eq)
        }
    }
    
    func testOptionTConversion() {
        let optionTEq = OptionT.eq(Id.eq(Option.eq(Int.order)), Id<Int>.functor())
        property("Left converted to none") <- forAll { (x : Int) in
            let eitherT = EitherT<ForId, Int, Int>.left(x, Id<Int>.applicative())
            let expected = OptionT<ForId, Int>.none(Id<Int>.applicative())
            return optionTEq.eqv(eitherT.toOptionT(Id<Int>.functor()), expected)
        }
        
        property("Right converted to some") <- forAll { (x : Int) in
            let eitherT = EitherT<ForId, Int, Int>.right(x, Id<Int>.applicative())
            let expected = OptionT<ForId, Int>.pure(x, Id<Int>.applicative())
            return optionTEq.eqv(eitherT.toOptionT(Id<Int>.functor()), expected)
        }
    }
}
