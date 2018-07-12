import XCTest
@testable import Bow

class TryTest: XCTestCase {
    
    var generator : (Int) -> Try<Int> {
        return { a in (a % 2 == 0) ? Try.invoke(constant(a)) : Try.invoke({ throw TryError.illegalState }) }
    }
    
    let eq = Try.eq(Int.order)
    let eqUnit = Try.eq(UnitEq())
    
    func testEqLaws() {
        EqLaws.check(eq: Try.eq(Int.order), generator: self.generator)
    }
    
    func testFunctorLaws() {
        FunctorLaws<ForTry>.check(functor: Try<Int>.functor(), generator: self.generator, eq: self.eq, eqUnit: self.eqUnit)
    }
    
    func testApplicativeLaws() {
        ApplicativeLaws<ForTry>.check(applicative: Try<Int>.applicative(), eq: self.eq)
    }
    
    func testMonadLaws() {
        MonadLaws<ForTry>.check(monad: Try<Int>.monad(), eq: self.eq)
    }
    
    func testApplicativeErrorLaws() {
        ApplicativeErrorLaws<ForTry, CategoryError>.check(applicativeError: Try<Int>.monadError(), eq: self.eq, eqEither: Try.eq(Either.eq(CategoryError.eq, Int.order)), gen: { CategoryError.arbitrary.generate })
    }
    
    func testMonadErrorLaws() {
        MonadErrorLaws<ForTry, CategoryError>.check(monadError: Try<Int>.monadError(), eq: self.eq, gen: { CategoryError.arbitrary.generate })
    }
    
    func testShowLaws() {
        ShowLaws.check(show: Try.show(), generator: self.generator)
    }
    
    func testFoldableLaws() {
        FoldableLaws<ForTry>.check(foldable: Try<Int>.foldable(), generator: self.generator)
    }
    
    func testTraverseLaws() {
        TraverseLaws<ForTry>.check(traverse: Try<Int>.traverse(), functor: Try<Int>.functor(), generator: self.generator, eq: self.eq)
    }
}
